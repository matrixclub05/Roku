/**
 * Created by Oleksii_Dymnich on 8/12/2015.
 */
var express = require('express');
var youtubedl = require("youtube-dl");
var youtubeapi = require("youtube-api");
var util = require("util");
var fs = require("fs");
var https = require("https");

var router = express.Router();

var GOOGLE_BASE_URL = "www.googleapis.com";
var YOUTUBE_API = "/youtube/v3/";
var APP_KEY = "AIzaSyAkE4L_Bb79OF5jBRNICDtgK2tJb3Nuz4M";


router.get('/recent', function(req, res, next) {
    var config = {};
    getYoutubeJSON(res, config);
});

router.get('/video/:id', function(req, res, next) {
    var id = req.params.id;
    var link = "https://www.youtube.com/watch?v=" + id;
    youtubedl.getInfo(link, function(err, info){
        if(err){
            res.status(500);
            res.send(util.format("%j", { error: err}));
            return;
        }

        var videoInfo = info['formats'].filter(function(vid){
            return vid.ext === "mp4" && !vid.hasOwnProperty('asr');
        });

        var video = videoInfo[videoInfo.length - 1];

        res.send(video.url);
    });
});

router.get('/popular', function(req, res, next) {
    var config = {
        chart: "mostPopular",
        maxResults: 50
    };
    getYoutubeJSON(res, config);
});

router.get('/popular/:pageToken', function(req, res, next){
    var config = {
        chart: "mostPopular",
        maxResults: 50,
        nextPage: req.params.pageToken
    };
    getYoutubeJSON(res, config);
});

function getYoutubeJSON(response, config){
    var query = "?";
    var defaultCfg = {
        part: "snippet",
        chart: "mostPopular",
        maxResults: "20"
    };

    config = config || {};
    query += "part=" + (config.part || defaultCfg.part);
    query += "&chart=" + (config.chart || defaultCfg.chart);
    query += "&maxResults=" + (config.maxResults || defaultCfg.maxResults);
    query += config.pageToken ? "&pageToken=" + config.pageToken : "";

    var options = {
        host: GOOGLE_BASE_URL,
        path: YOUTUBE_API + "search" + query + "&key=" + APP_KEY,
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    };

    var req = https.get(options, function(res) {
        var data = "";
        res.on('data', function(d) {
            data += d;
        });
        res.on('end', function(){
            response.json(parseYoutubeJSON(data));
        });
    });
    req.end();

    req.on('error', function(e) {
        console.error(e);
    });
}

function parseYoutubeJSON(str){
    var data = JSON.parse(str);
    var srcItems = data.items;
    var obj = {
        info: {
            totalResults: data.pageInfo.totalResults,
            nextPageToken: data.nextPageToken,
            prevPageToken: data.prevPageToken
        },
        list: []
    };
    for (var i = 0; i < srcItems.length; i++) {
        var item = srcItems[i];
        var rokuItem = {
            id: item.id.videoId,
            title: item.snippet.title,
            Description: item.snippet.description,
            SDPosterUrl: item.snippet.thumbnails.high.url.replace("https", "http"),
            HDPosterUrl: item.snippet.thumbnails.high.url.replace("https", "http")
        };
        obj.list.push(rokuItem);
    }
    return obj;
}

module.exports = router;