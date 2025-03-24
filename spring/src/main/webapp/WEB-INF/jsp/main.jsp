<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<spring:eval expression="@environment.getProperty('server.type')" var="serverType" /><spring:eval expression="@environment.getProperty('spring.datasource.url')" var ="datasourceUrl"/><spring:eval expression="@environment.getProperty('spring.datasource.username')" var ="userName"/>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />

<!-- 상단공지 롤링(디자인때문에 여기에 선언) -->
<style>
ul.marquee-body {
  margin: 0;
  list-style: none;
  font-weight: 600;
  flex: 1;
  overflow: hidden;
  height: inherit;
}
.marquee-body > li {
	width: 100% !important;
	margin-left: 0px !important;
	height: inherit !important;
	background: transparent !important;
}
.marquee-body > li > div:hover {
	background: transparent !important;
	cursor: pointer;
	color: #0b4e82 !important;
	font-weight: bold;
}
.marquee-body > li > div {
	white-space: nowrap;text-overflow: ellipsis;color: #0b4e82; line-height: 37px;
}
</style>
<!-- /상단공지 롤링(디자인때문에 여기에 선언) -->
<script type="text/javascript">
	var __marking_able = false; 			// 마스킹 여부
	var __logoutTimerMin = "${logout_timer_min}";		// 로그아웃 타이머(분)
	var __logoutDelayMin = "${logout_delay_min}";		// 로그아웃 대기시간(분)

	var paperTimer; //쪽지 풀링방식 타이머객체
	var paperPollingTime = 1000 * 60 * 5; 	//쪽지 폴링타임 설정(5분)
	var notcieCntDom;
	var paperCntDom;

	var autocompleteMenu;
	
	// 메뉴창 로드 여부 (그리드 깨짐 현상 제거를 위해 )
	var isIframeLoad = true;
	
	// 탭 헤더 메뉴 클릭 (메뉴 열 때 마다 상단에 리스트로 노출되는 부분)
	// - 사이드 메뉴 클릭 시 이벤트가 2개가 실행 됨 (그 이벤트 중 탭 헤더 메뉴 클릭에만 적용해야 되는 로직이 있음)
	// - 해당 변수를 사용하여 탭 헤더 클릭 여부를 판별하여 분기 처리함 (tt.tabs - onSelect() 부분)
	var isHeaderMenuClick = false; 

	// 메뉴찾기 너무 힘들어서 만듬 by 김태훈
	<c:if test="${SecureUser.mem_no eq 'MB00000431'}">
// 	    var _menuListJson = ${menuListJson};
		var _menuListJson;

		// 개발다안된것같음... 확인해봐야함!!! 주석해놓음
		function setSearchMenuList() {
			_menuListJson = ${menuListJson};
			/* var memNo = '${SecureUser.mem_no}';
			var param = { 'mem_no' : memNo };
			if(memNo='') {
				console.log('in' + '${SecureUser.mem_no}');
			}
			console.log('in' + '${SecureUser.mem_no}');
			$M.goNextPageAjax("/comp/comp0101/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						console.log('out:', result);
						if(result.success) {
							_menuListJson = result.list;
							console.log(result);
						};
					}
				); */ 
		}
	    function fnRemoveAutocomplete() {
		   setTimeout(function(){ autocompleteMenu.innerHTML='';}, 200);
	    }
	    // IE includes 오류 수정
	    if (!String.prototype.includes) { String.prototype.includes = function(search, start) { 'use strict'; if (search instanceof RegExp) { throw TypeError('first argument must not be a RegExp'); } if (start === undefined) { start = 0; } return this.indexOf(search, start) !== -1; }; }
	    function autoComplete(arrays, Input) {
	    	var array = [];
	    	for (var i = 0; i < arrays.length; ++i) {
	    		if (arrays[i].menu_name.toLowerCase().includes(Input.toLowerCase())) {
	    			array.push(arrays[i]);
	    		}
	    	}
	    	return array;
	        //return arrays.filter(e => e.menu_name.toLowerCase().includes(Input.toLowerCase()));
	    }
	    function getValue(val) {
	         if(!val) {
	        	 autocompleteMenu.innerHTML='';
	           return
	         }
	         var data = autoComplete(_menuListJson, val);
	         var res = '';
	         for (var i = 0; i < data.length; ++i) {
	        	 res += '<li><a href="javascript:void(0);" class="target" url="'+data[i].url+'" title="'+data[i].menu_name+'"><span>'+data[i].menu_name+'</span></a></li>';
	         }
	         res += '';
	         autocompleteMenu.innerHTML = res;
	    }
    </c:if>

	$(document).ready(function() {
		$('#tt').tabs({
			onSelect: function(title, index) {
				// 탭 헤더 클릭 이벤트 발생
				if(isHeaderMenuClick) {
					// 한번 실행 하면 false 로 초기화
					isHeaderMenuClick = false;
					
					// 재호 Q&A - 16811 (사용에 불편이 있어 해제 요청)
					// 탭 헤더 클릭 이벤트 && iframe 로딩이 안된 상태면
					// if(!isIframeLoad) {
					// 	onLoadAlert(); // 알림 노출
					// 	var tabSize = $(".tabs").find("li").length - 1;
					// 	$('#tt').tabs('select', tabSize); // 탭 이동 안 시키기
					// 	return;
					// }
				} else {
					// onSelect 가 사이드 메뉴 클릭에서 실행 된 건지 헤더 탭 클릭에서 실행 된 건지 알 수 없음
					// - false 일 때 true 로 변경하여 다음 클릭 때 무조건 이벤트 발생 하는 방식으로 개발 (isIframeLoad 상태를 보기 때문에 괜찮은 듯)
					isHeaderMenuClick = true;
				}
				
				if (__fnSetActionDate) {
					__fnSetActionDate();
				}
			},
			onBeforeClose : function(title, index) {
				var target = $(this).tabs('getTab', title).panel("options");

				if (target.isPwdCheckMenu) {
					// 비밀번호 체크페이지 닫을때만 동작
					var tabList = $(this).tabs('tabs');
					var existsCloseAfterMenu = false;

					for (var i in tabList) {
						var title = tabList[i].panel("options").title;
						var isPwdCheckMenu = tabList[i].panel("options").isPwdCheckMenu;

						if (target.title !=  title && isPwdCheckMenu) {
							existsCloseAfterMenu = true;
							break;
						}
					}

					if (existsCloseAfterMenu == false) {
						console.log("남아있는 pwdChkPage없음 타이머 제거");
						if (window.fnClearTimeoutInterval) {
							window.fnClearTimeoutInterval();
						}
					}

				}
			},
		});

	   var timer = 0;
	   var delay = 200;
	   var prevent = false;
	   var isLeftHide = false;
	   notcieCntDom = $("#no_read_notice_cnt");
	   paperCntDom = $("#no_read_paper_cnt");

		$(document).on("click", "#menuName", function() {
			$(this).next().slideToggle(0, function() {
				var display = $(this).css("display");
				(display == 'none') ? $(this).parent().removeClass("active") : $(this).parent().addClass("active");
			});
		});

	   $('.acco-menu-wrap').click(function() {
		   $(this).find('i').toggleClass("material-iconsarrow_back_ios, material-iconsarrow_forward_ios");
		   if (isLeftHide == false){
			   $('body').layout('collapse', 'west');
			   isLeftHide = true;
		   } else {
				$('body').layout('expand', 'west');
				isLeftHide = false;
		   }
	   })

	   $('#closeAllTabs').click(function() {
		   if(confirm("모든 탭을 닫으시겠습니까?")){
			    var count = $('#tt').tabs('tabs').length;
					for(var i=count-1; i>=0; i--){
						$('#tt').tabs('close',i);
						$('#closeAllTabs').css('display', 'none');
				    }
					goMainContent("mainContent", "/mainContent");
		   }
	   })

	   goMainContent("mainContent", "/mainContent");

	   initCnt();

	   if ($M.getValue("new_page_yn") == "Y") {
		   // 상단 메뉴 + 버튼 클릭 시 새창에 페이지 로드 및 좌측에 해당 메뉴 세팅.
		   goLeftMenuPanel($M.getValue("menu_seq"));
	   } else {
		   // 페이지 로드 시, 제일 첫번째 선택
		   goLeftMenuPanel(1);
		   if ("${main_type_gb}" == "B") {
				fnToggleNoticeAndMenu('init');
		   }
	   }

		$(document).on("click", ".target", function () {
			// 재호 Q&A - 16811 (사용에 불편이 있어 해제 요청)
			// iframe 로드가 안 됐다면 알림 노출 후 return 
			// if(!isIframeLoad) {
			// 	onLoadAlert();
			// 	return;
			// }
			
			var ts = $(this);
			var url = ts.attr("url");
			var title = ts.attr("title");
			$("a[class=target]").parent().removeClass("active");
			ts.parent().addClass("active");

			timer = setTimeout(function () {
				if (!prevent) {
					if (url.indexOf('/cust/cust0108') < 0) {
						goContent(title, url);
					} else {
						// ARS인 경우 새창 오픈
						goNewPageARS('/cust/cust0108');
					}
				}
				prevent = false;
				/* 탭 닫기 버튼이 display none일 경우 탭 닫기 버튼 block으로 변경 */
				if ($('#closeAllTabs').css('display') == "none") {
					$('#closeAllTabs').css('display', 'block');
				}
			}, delay);
		})

	   	// 즐겨찾기
		$(document).on("click", "#bookmarkMenuBtn", function() {
		   	// class: dpn으로 노출여부
			$(".favorite-menu").toggleClass("dpn");
			// 즐겨찾기 메뉴가 열릴때만 ajax 작동
			if($("#bookmarkMenu").hasClass("dpn")) {
				return;
			};
		   // 즐겨찾기 메뉴 AJAX 호출
		   goBookmarkMenu();
		});

	    // 상단공지 롤링
		var ticker = function () {
		    timer = setTimeout(function () {
		   	// 2개이상일때만 롤링시작
		    if ($(".marquee-body li").length < 2) {
					return false;
			}
		      $(".marquee-body li:first").animate(
		        { marginTop: "-36px" },
		        400,
		        function () {
		          $(this).detach().appendTo("ul.marquee-body").removeAttr("style");
		        }
		      );
		      ticker();
		    }, 2500);
		  };
		  var tickerover = function () {
		    $(".marquee-body").mouseover(function () {
		      	clearTimeout(timer);
		    });
		    $(".marquee-body").mouseout(function () {
		    	ticker();
		    });
		  };
		  tickerover();
		  ticker();

		  // 근무관리 메시지
		  var workMsg = "${_workMsg}";
		  if(workMsg != "") {
			  alert(workMsg.replace("&gt;" , ">"));
			  // (Q&A 13079) 출근관리 여부 추가.. 211022 김상덕
		  } else if("${SecureUser.auto_login_yn}" == "Y" && "${timeBean.in_yn}" == "N" && "${SecureUser.attend_mng_yn}" == "Y") {	// 자동로그인이고, 출근처리를 안했으면, 출근관리여부 Y이면 알림.
			  goMemWork('IN');
		  }
	});

	function Interval(callback, delay) {
	    var timerId, start, remaining = delay;

	    this.pause = function() {
	        window.clearTimeout(timerId);
	        remaining -= new Date() - start;
	    };

	    var resume = function() {
	        start = new Date();
	        timerId = window.setTimeout(function() {
	            remaining = delay;
	            resume();
	            callback();
	        }, remaining);
	    };

	    this.resume = resume;

	    this.resume();
	}

	// 미확인공지, 안읽은 쪽지 갯수 갱신(탑 공지는 조회안함)
	function fnCntRenewal() {
		var endDt = "${inputParam.s_current_dt}";
		var startDt = $M.dateFormat($M.addMonths($M.toDate(endDt), -1), "yyyyMMdd");
		var param = {
			"s_start_dt" : startDt,
			"s_end_dt" : endDt,
			"s_tab_gubun" : "R",
			"s_main_yn" : "Y",
		};
		$M.goNextPageAjax("/mmyy/mmyy0102/cnt", $M.toGetParam(param), {method : 'get', loader : false},
				function(result) {
					if(result.success) {
						notcieCntDom.text(result.notice_cnt>=100 ? '99+' : result.notice_cnt);
						paperCntDom.text(result.cnt>=100 ? '99+' : result.cnt);
					};
				}
			);
	}

	// 시작할때 조회용
	function initCnt() {
		var endDt = "${inputParam.s_current_dt}";
		var startDt = $M.dateFormat($M.addMonths($M.toDate(endDt), -1), "yyyyMMdd");
		var param = {
			"s_start_dt" : startDt,
			"s_end_dt" : endDt,
			"s_tab_gubun" : "R",
			"s_main_yn" : "Y",
			"s_top_notice_yn" : "Y"
		};
		$M.goNextPageAjax("/mmyy/mmyy0102/cnt", $M.toGetParam(param), {method : 'get', loader : false},
				function(result) {
					if(result.success) {
						notcieCntDom.text(result.notice_cnt>=100 ? '99+' : result.notice_cnt);
						paperCntDom.text(result.cnt>=100 ? '99+' : result.cnt);
						if(result.cnt > 0) {
							timers.pause();
							fnConfirm("쪽지가 <span style='color:blue;'>" + result.cnt + "</span>개 도착하였습니다.확인하시겠습니까?",
								function(flag) {
									if(flag) {
										goPaperDetail();
									}
								},
								function(){
									//alert("닫음");
									timers.resume();
								}
							);
						}
					};
				}
			);
	}

	var timers = new Interval(function() {
		console.log("Interval... ->", new Date());
		var endDt = "${inputParam.s_current_dt}";
		var startDt = $M.dateFormat($M.addMonths($M.toDate(endDt), -1), "yyyyMMdd");

		var param = {
			"s_start_dt" : startDt,
			"s_end_dt" : endDt,
			"s_tab_gubun" : "R",
			"s_main_yn" : "Y",
			"s_top_notice_yn" : "Y"
		};
		timers.pause();
		$M.goNextPageAjax("/mmyy/mmyy0102/cnt", $M.toGetParam(param), {method : 'get', loader : false},
			function(result) {
				if(result.success) {
					notcieCntDom.text(result.notice_cnt>=100 ? '99+' : result.notice_cnt);
					paperCntDom.text(result.cnt>=100 ? '99+' : result.cnt);
					var noticeSeqArr = [];
					if (result.notice_top) {
	                    var notice = result.notice_top;
						for (var i = 0; i < notice.length; ++i) {
							noticeSeqArr.push(notice[i].notice_seq);
							if (document.body.contains(document.getElementById("notice_seq_"+notice[i].notice_seq)) == false) {
								console.log("신규 추가");
								var template = "";
									template += '<li>';
									template += '<div onclick="javascript:goNoticeDetail('+notice[i].notice_seq+')" id="notice_seq_'+notice[i].notice_seq+'">'+notice[i].title+'</div>';
									template += '</li>';
									$(template).appendTo("#marquee-body");
							}
						}
					}

					// 삭제됐는지 판별
					var body = document.getElementById("marquee-body");
					if (body != null) {
						var children = body.children;
						for (var i = children.length-1; i >= 0; --i) {
							var seq = parseInt(children[i].firstElementChild.id.substr(11));
							if (noticeSeqArr.indexOf(seq) == -1) {
								console.log("삭제됨", seq);
								children[i].remove();
							}
						}
					}

					if (!window.logoutTimerInterval) {
						if(result.cnt > 0){
							console.log("쪽찌 있음!! 확인 누를때까지 대기");
							timers.pause();
							fnConfirm("쪽지가 <span style='color:blue;'>" + result.cnt + "</span>개 도착하였습니다.확인하시겠습니까?",
									function(flag){
										if(flag) {
											goPaperDetail();
										}
									},
									function(){
										setTimeout(function() {
											console.log("쪽지 있음 ===> "+paperPollingTime/1000+"초 후 다시 시작!");
											timers.pause();
											timers.resume();
										}, paperPollingTime);
									}
							);
						}
						if(result.cnt == 0) {
							console.log("쪽지 없음 ===> 다시 시작!");
							timers.pause();
							timers.resume();
						}
					} else {
						setTimeout(function() {
							console.log("로그아웃 연장팝업 있음 ===> "+paperPollingTime/1000+"초 후 다시 시작!");
							timers.pause();
							timers.resume();
						}, paperPollingTime);
					}
				};
			}
		);
	}, paperPollingTime);

	// 상단 공지 상세
   function goNoticeDetail(seq) {
		if (seq == "") {
			return false;
		}
	   	var param = {
			"notice_seq" : seq
		};
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=800, left=0, top=0";
		$M.goNextPage('/mmyy/mmyy0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
   }

	// 바코드 팝업호출
	function goBarcode() {
		$M.goNextPageLayer("/comp/comp0605");
	}

	function goPaperDetail() {
		//쪽지함 상세로 띄우기 ( 팝업 )
  	 	$M.goNextPageAjax('/session/check', '' , {method : 'get'},	 //세선체크
 			function(result){
				}
		  	);
		var param = { 's_auto_papercheck' : "Y" };
	    $M.goNextPage('/mmyy/mmyy0102p02', $M.toGetParam(param), {popupStatus : getPopupProp(1600, 850)});
	    //goContent("쪽지함", "/mmyy/mmyy0102");
	}

	function goMainContent(title, url) {
	  	 $M.goNextPageAjax('/session/check', '' , {method : 'get'},
			function(result){

			}
		  );
	  	  var content = '<iframe src="' + url + '" id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="yes"></iframe>';
	      $("#mainContent").html(content);
	      $("#mainContent").show();
	      $("#back_btn").hide();
	   }

		// 쪽지함 이동
		function goPaperRoom() {
			goContent('쪽지함', '/mmyy/mmyy0102');
		}

		// iframe load 함수
		// - iframe 로드 완료로 변경
		function onLoadHandler() {
			isIframeLoad = true;
		}
		
		// iframe load alert 함수
		function onLoadAlert() {
			alert('메뉴 로딩 중 입니다.\n완료 후 다시 진행해주세요.');
		}
		
		function goContent(title, url) {
		  isIframeLoad = false; // iframe load 미 완료 상태로 변경
			isHeaderMenuClick = false; // 탭 헤더 이벤트 제거
		 
			$M.goNextPageAjax('/session/check', '' , {method : 'get'},
				function(result) {}
			);
			$("#mainContent").hide();
			$("#back_btn").show();
	
			var pwdMenuList = ${pwdMenuListJson};
			var isPwdChkMenu = false;
	
			for (var i in pwdMenuList) {
				if (title == pwdMenuList[i].menu_name) {
					isPwdChkMenu = true;
					break;
				}
			}
			
			// iframe 로드 완료 되면 onLoadHandler 함수 호출
			var content = '<iframe src="' + url + '" id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="yes" onload="onLoadHandler()" onerror="onLoadHandler()"></iframe>';
			
			var tabs = $("#tt").tabs('getTab', title);
			var tabSize = $(".tabs").find("li").length;
			if (tabSize >= 10) {
			 if (tabs == null) {
				if (confirm('새로운 메뉴 추가로 이전에 열린 메뉴를 닫으시겠습니까?')) {
					 $("#tt").tabs("close", 0);
				} else {
					 return;
				}
			 }
			}
	
			if (tabs == null) {
				$('#tt').tabs('add', {
					title : title,
					content : content,
					closable : true,
					fit : true,
					/* tabWidth : 'auto', */
					narrow : true,
					pill : true,
					isPwdCheckMenu : isPwdChkMenu,
				});
			} else {
				$('#tt').tabs('add', {
					title : title,
					content : content,
					closable : true,
					fit : true,
					/* tabWidth : 'auto', */
					narrow : true,
					pill : true,
					isPwdCheckMenu : isPwdChkMenu,
				});
				$("#tt").tabs("close", title);
			}
		}


	function goLeftMenuPanel(menu_seq) {

		// 레프트메뉴(원래 나오던거)
    	var leftMenuArea = $("#leftMenuArea");

    	// 즐겨찾기(추가)
    	var favoritArea = $("#leftFavoritArea");

    	// 즐겨찾기가 활성화 될 경우 즐겨찾기 비활성활성화로 변경 및 Left 활성화
    	if (favoritArea.hasClass('dpn') == false) {
    		favoritArea.empty();
    		leftMenuArea.empty();
    		favoritArea.toggleClass('dpn');
    		leftMenuArea.toggleClass('dpn');
    	}

    	$('.top-menu-active-toggle').parent().removeClass("active");
    	$('#top-menu'+menu_seq).addClass("active");
    	$M.goNextPageAjax('/leftPanel/' + menu_seq, '', '',
   			function(result) {
   		 		if(result.success) {
   		 			$("#left").scrollTop(0); // 탑메뉴 이동 시, 레프트패널 스크롤 맨위로 by 김태훈
   		 			leftMenuArea.empty();
   		 			leftMenuArea.append(result.menu_str);
   		 		}
   			}
   		 );
    }

    function goLogout() {
    	<%--if(confirm('로그아웃 하시겠습니까?')) {
    		$M.goNextPage('/login');
    	}--%>
    	// 로그아웃시 연결된 기기에서 자동로그 아웃 풀림
    	$M.goNextPageAjaxMsg('로그아웃 하시겠습니까?', '/logout', '', '',
   			function(result) {
   		 		if(result.success) {	// 로그아웃 성공
   		 			$M.goNextPage('/');
   		 		}
   			}
   		 );
    }

    // 해당 계정의 즐겨찾기 목록
	function goBookmarkMenu() {
		// AJAX 실행
		$M.goNextPageAjax("/comp/comp0101/bookmark", "", {loader : false},
			function(result) {
				if(result.success) {
					$("#bookmarkList").empty();
					// 해당 계정의 즐겨찾기 개수
					console.log("# list cnt : " + result.list.length);
					if(result.list.length > 0) {
						$(".text-primary").addClass("dpn");
						// 헤당 계정의 즐겨찾기 목록출력
						$.each(result.list, function() {
							var template = "";
								template += "<li>";
								template += "	<a href='javascript:void(0);' class='target' url='" + this.url + "' title='" + this.menu_name + "'><span>" + this.menu_name + "</span>";
								template += "		<i class='material-iconschevron_right'></i>";
								template +=	"	</a>";
								template +="</li>";
							$("#bookmarkList").append(template);
						});

                        $("#bookmarkMenu").unbind()
                        $("#bookmarkMenu").bind("mouseleave",function(){
                            $(".favorite-menu").toggleClass("dpn");
                            $(this).unbind()
                        });
					} else {
						// class: dpn으로 노출여부
						$(".text-primary").removeClass("dpn");
					};
				};
			}
		)
		// END AJAX
	}
    // END goBookmarkMenu

	/**
	 * 즐겨찾기설정 레이어팝업
	 * @returns
	 */
	function goBookmarkPopup() {
		// 레이어팝업 팝업위치 옵션(수정필요)
		//$M.goNextPage('/comp/comp0101', "", {popupStatus : poppupOption});
		//$M.goNextPageAjax('/comp/comp0101', "", {popupStatus : poppupOption, dataType : 'html'});
		$M.goNextPageLayer("/comp/comp0101");
	}

    function setOrgMapPanel() {

    }

    function goMyInfo() {
		   var param = {};
		   $M.goNextPage('/comm/comm0116', $M.toGetParam(param), {popupStatus : getPopupProp(1600, 850)});
	 }

    function fnSendSms() {
    	var param = {
			   'name' : "",
			   'hp_no' : ""
		   };
		openSendSmsPanel($M.toGetParam(param));
    }

	//쪽지쓰기
    function fnSendPaper() {
    	var param = {};
    	openSendPaperPanel(param);
    }

    // 직원출퇴근처리
    function goMemWork(type) {
    	var msg = (type == 'IN' ? '출근' : '퇴근') + ' 처리를 하시겠습니까?';
    	var url = type == 'IN' ? '/main/memInWork' : '/main/memOutWork';

    	$M.goNextPageAjaxMsg(msg, url, "", {method: "POST"},
   	  		function (result) {
   	  	    	if (result.success) {
   	  	    		$M.goNextPage('/main');
   	  	        }
   			}
   		);
    }

    function changeMem(selObj) {
    	var param = "cover_mem_no=" + selObj.value;
    	alert('선택된 사용자로 변경됩니다.\n발생할 수 있는 모든 책임은 ${SecureUser.user_name}님 한테 있습니다.');
    	$M.goNextPageAjax("/main/checkCoverMem", param, {method: "GET"},
   	  		function (result) {
   	  	    	if (result.success) {
   	  	    		// 성공시 로그인변경
	   	 		 	$M.goNextPageAjax('/main/changeCoverMem', param, {method:'post'},
	   	 				function(result) {
	   	 		 			// 성공여부 상관없이 메인호출
   	 			 			$M.goNextPage('/main');
	   	 				}
	   	 			);
   	  	        } else {
		 			$M.goNextPage('/main');
   	  	        }
   			}
   		);
    }

    // 상단 메뉴 + 버튼 클릭시 새창에 페이지 오픈.
    function goNewPage(menu_seq, menu_name) {
    	var newMenu = window.open('/main?newPageYn=Y&menuSeq=' + menu_seq + '&menuName=' + menu_name);
    }

    // 상단 메뉴 + 버튼 클릭시 새창에 페이지 오픈.
    function goNewPageARS(url) {
		$M.goNextPage(url, '', {popupStatus : ''});
    }

    // 탑메뉴 토글
    function fnToggleNoticeAndMenu(init) {
    	var topToggleBtn = $("#topToggleBtn");

    	// 토글 버튼의 클래스를 보고 공지를 보여줄지 판단
    	var topToggleBtnClass = topToggleBtn.attr('class');
    	$(".toggle-top-notice-wrap").toggleClass("dpn");
		$(".toggle-top-menu-wrap").toggleClass("dpn");

		// 토글 버튼의 아이콘 모양을 바꿈(icon-btn-menuclose <-> icon-btn-menuclose)
    	topToggleBtn.toggleClass("icon-btn-menuclose icon-btn-menuopen");

		// 탑메뉴 토글 시, 레프트도 토글
		var mainTypeGb = "G";
		if (topToggleBtn.hasClass("icon-btn-menuopen")) {
			$("#leftMenuArea").addClass("dpn");
			$("#leftFavoritArea").removeClass("dpn");
			mainTypeGb = "B";
			fnRefreshLeftFavorit();
		} else {
			$("#leftFavoritArea").addClass("dpn");
			$("#leftMenuArea").removeClass("dpn");
		}
		var param = {
	main_type_gb : mainTypeGb
	}
	if (init === undefined) {
		$M.goNextPageAjax('/main/changeMainTypeGb', $M.toGetParam(param), {method:'post', loader : false},
				function(result) {
					// 성공여부 상관없이 메인호출

				}
		);
	}

	}

    // 레프트메뉴 토글(즐겨찾기)
    function fnToggleFavoritLeft() {
    	// 레프트메뉴(원래 나오던거)
    	var leftMenuArea = $("#leftMenuArea");

    	// 즐겨찾기(추가)
    	var favoritArea = $("#leftFavoritArea");

    	// 왼쪽에 즐겨찾기와 레프트 메뉴 토글
    	/* leftMenuArea.toggleClass("dpn");
    	favoritArea.toggleClass("dpn"); */

    	// 무조건 즐겨찾기만 보여주는걸로 변경
    	leftMenuArea.addClass("dpn");
    	favoritArea.removeClass("dpn");

    	// 즐겨찾기가 활성화 될 경우 즐겨찾기 불러오기
    	if (favoritArea.hasClass('dpn') == false) {
    		fnRefreshLeftFavorit();
    	}
    }

    function fnRefreshLeftFavorit() {
    	if(${SecureUser.mem_no eq 'MB00000431'}) {
    		setSearchMenuList();
    	}
    	console.log("fnRefreshLeftFavorit");
    	$M.goNextPageAjax("/comp/comp0101/bookmark", "", {loader : false},
				function(result) {
					if(result.success) {
						$("#leftFavoritArea").empty();
						// 해당 계정의 즐겨찾기 개수
						var template = "";
							template += "<ul>";
							<c:if test="${SecureUser.mem_no eq 'MB00000431'}">
								template += "<li class='active'>";
								template += "<a class='title-wrap'>"
								template += "<div style='width : 100%;'><input type='search' style='padding-left: 3px;' class='form-control' placeholder='메뉴명..(전산담당만나옴)' onkeyup='getValue(this.value)' onfocus='getValue(this.value)' onblur='javascript:fnRemoveAutocomplete()'><ul id='autocompleteMenu'></ul></div>";
								template += "</a>";
								template += "</li>";
							</c:if>
							template += "<li class='active'>";
							template += "<a class='title-wrap'  href='javascript:goBookmarkPopup();' >";
							template += "<div class='title'>";
							template += "<span>업무메뉴</span>";
							template += "</div>";
							template += "<div><span>+메뉴설정</span></div>";
							template += "</a>";
							template += "<ul>";
						if(result.list.length > 0) {
							// 헤당 계정의 즐겨찾기 목록출력
							$.each(result.list, function() {
									template += "<li>";
									template += "	<a href='javascript:void(0);' class='target' url='" + this.url + "' title='" + this.menu_name + "'><span>" + this.menu_name + "</span>";
									template +=	"	</a>";
									template +="</li>";
							});
						} else {
							template += "<li style='text-align: center; height: 3.5vh; padding-top: 0.5vh;'>메뉴를 설정하세요.</li>"
						}
						template += "</ul>";
						template +="</ul>";
						$("#leftFavoritArea").append(template);
						<c:if test="${SecureUser.mem_no eq 'MB00000431'}">
				    		autocompleteMenu = document.getElementById('autocompleteMenu');
				    		autocompleteMenu.innerHTML='';
			    		</c:if>
					};
				}
			)
    }

    // 업무DB
    function goWorkData() {
    	$M.goNextPageAjax('/workDb/checkToken', '', {loader : false},
			function(result) {
	 			if(result.auth_yn == 'Y') {
	 				// 2022.04.28 김상덕. 4월26일 YK회의에서 대표님 요청으로 알림 제거.
// 	 				alert("업무DB 사용 시에는 라인에 로그인이 되어 있어야 합니다.");
	 				$M.goNextPage('/workDb/workDb0101', '', {popupStatus : getPopupProp(1200, 850)});
	 			} else {
	 				alert("업무DB 사용 시에는 라인계정연동이 필요합니다(최초1회).\n연동설정 페이지로 이동합니다.");
	 			    $M.goNextPage('/comm/comm0116', '', {popupStatus : getPopupProp(1600, 850)});
	 			}
			}
		);
    }
    // 업무DB
    function goWorkData2() {
		$M.goNextPage('/workDb2/workDb0101', '', {popupStatus : getPopupProp(1200, 850)});
    }

    // 가격조건표
	function goMachinePlant() {
		// alert("가격조건표 팝업");
		$M.goNextPage('/comp/comp0508', "", {popupStatus : ""});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<input type="hidden" id="new_page_yn" name="new_page_yn" value="${newPageYn}">
	<input type="hidden" id="menu_seq" name="menu_seq" value="${menuSeq}">
   <!-- top -->
	<div id="header" data-options="region:'north',border:false" class="top-wrap"
		 style="overflow-y:hidden;display: flex;width: 100%;min-width: 1280px; height: 60px;
			<c:if test="${serverType eq 'dev'}">background: pink;</c:if>
			<c:if test="${serverType ne 'dev'}">background: #4598d9;</c:if>
		    <c:if test="${serverType eq 'default'}">background: gold;</c:if> ">
      <!-- 로고 -->
      <div class="topmenu-logo">
         <a href="javascript:$M.goNextPage('/main');"><img src="/static/img/topmenu-logo.png" alt="YK건기 로고"></a>
      </div>
      <!-- /로고 -->
      <!-- top 메뉴 전체 (top-menu-left, top-menu-right) -->
      <div class="top-container">
         <!-- top-menu-left -->
         <div class="top-menu-left">
         	<button type="button" class="btn btn-primary btn-menu" onclick="javascript:fnToggleNoticeAndMenu()">
                <i class="icon-btn-menuclose" id="topToggleBtn"></i>
            </button>
            <div class="toggle-top-notice-wrap dpn">
            	<div style="display: flex; align-items: center; justify-content: center;">
	            	<div style="display: flex;
							    width: 650px;
							    min-width: 630px;
							    align-items: center;
							    margin-left: 15px;
							    color: #146bae;
							    font-size: 14px;
							    padding: 8px 8px 8px 13px;
							    background: #fff;
							    border-radius: 20px; height: 37px;">
    					<i class="material-iconsnotifications_none" style="color: #146bae"></i>
    					<c:if test="${SecureUser.org_type ne 'AGENCY'}">
	    				<ul id="marquee-body" class="marquee-body" style="display: block; margin-left: 5px;"> <!-- marquee-body -->
	    					<c:forEach items="${notice_top}" var="item">
	    						<li>
			                        <div onclick="javascript:goNoticeDetail(${item.notice_seq})" id="notice_seq_${item.notice_seq}">${item.title }</div>
			                    </li>
	    					</c:forEach>
	                    </ul>
	                    </c:if>
		            </div>
	            </div>
	            <%-- <a href="javascript:goNoticeDetail()" class="notice toggle-top-notice-wrap dpn">
	            	<input type="hidden" name="notice_top_notice_seq" value="${notice_top.notice_seq}">
	                <i class="material-iconsnotifications_none"></i>
	                <span id="notice_top_title">${notice_top.title }</span>
	            </a> --%>
            </div>
            <ul class="toggle-top-menu-wrap">
            	<c:forEach var="item" items="${topMenuList }">
            		<li id="top-menu${item.menu_seq}">
            			<a href="javascript:void(0);" class="top-menu-item new-window top-menu-active-toggle">
            				<i class="${item.icon_class }" onclick="goNewPage(${item.menu_seq}, '${item.menu_name}')"></i>
           					<a href="javascript:void(0);" onclick="goLeftMenuPanel(${item.menu_seq })" class="top-menu-item menu-go" style="font-weight: 600;">${item.menu_name }</a>
           				</a>
           			</li>
            	</c:forEach>
            	<c:if test="${showDevMenu eq 'Y'}"><li id="top-menu0"><a href="javascript:void(0);" onclick="goLeftMenuPanel(0)" class="top-menu-item top-menu-active-toggle"> <i class="${item.icon_class }"></i><span>개발참고</span></a></li></c:if>
            </ul>
         </div>
         <!-- /top-menu-left -->
         <!-- top-menu-right -->
         <div class="top-menu-right">

            <ul><%-- 앱 버전정보 표시 --%>
<!--                <li class="top-menu-item">Ver.02-02 14시</li> -->
				<%-- 바코드는 서비스, 부품부만 노출 --%>
   				<c:if test="${pageContext.request.serverName eq 'localhost' or serverType eq 'dev'}">
					<span style="color: block">
						${datasourceUrl.indexOf('124') > -1 ? '*운영으로 접속중*' : '개발'} ${userName}
					</span>
					<span style="color: block"># ${serverType} # ${SecureUser.mem_no} # ${SecureUser.org_code}</span>
				</c:if>
				<li><a href="javascript:void(0);" class="top-menu-item" onclick="javascript:goMachinePlant();"><i class="icon-btn-pricetable"></i><span>가격조건표</span></a></li>
			   <c:if test="${drive_show_yn eq 'Y'}"><%-- 부서 및 업무권한에 /workDb/workDb0101 권한 있는 사람만 노출 --%>
<%--			   		<c:if test="${drive_new_yn eq 'Y'}">--%>
<%--			   			<li><a href="javascript:void(0);" class="top-menu-item pr" onclick="javascript:goWorkData();"><span class="new-icon">N</span><i class="icon-btn-db"></i><span>업무DB</span></a></li>--%>
<%--			   		</c:if>--%>
<%--			   		<c:if test="${drive_new_yn eq 'N'}">--%>
<%--			   			<li><a href="javascript:void(0);" class="top-menu-item" onclick="javascript:goWorkData();"><i class="icon-btn-db"></i><span>업무DB</span></a></li>--%>
<%--			   		</c:if>--%>

				   <c:if test="${drive_new_yn eq 'Y'}">
			   			<li><a href="javascript:void(0);" class="top-menu-item pr" onclick="javascript:goWorkData2();"><span class="new-icon">N</span><i class="icon-btn-db"></i><span>업무DB</span></a></li>
			   		</c:if>
			   		<c:if test="${drive_new_yn eq 'N'}">
			   			<li><a href="javascript:void(0);" class="top-menu-item" onclick="javascript:goWorkData2();"><i class="icon-btn-db"></i><span>업무DB</span></a></li>
			   		</c:if>
			   </c:if>
               <c:if test="${fn:contains('56', fn:substring(SecureUser.org_code, 0, 1))}"><li><a href="javascript:void(0);" class="top-menu-item" onclick="javascript:goBarcode();"> <i class="icon-btn-barcode"></i><span>바코드</span></a></li></c:if>
               <li><a href="javascript:void(0);" class="top-menu-item" onclick="javascript:openOrgMapMainPanel('setOrgMapMainPanel');"> <i class="icon-btn-group"></i><span>조직도</span></a></li>
               <li><a href="javascript:void(0);" class="top-menu-item" onclick="javascript:fnSendPaper();"> <i class="icon-btn-memo"></i><span>쪽지쓰기</span></a></li>
               <c:if test="${SecureUser.org_type ne 'AGENCY'}"><li><a href="javascript:void(0);" class="top-menu-item" onclick="javascript:fnSendSms();"> <i class="icon-btn-sms"></i><span>문자</span></a></li></c:if>
               <%-- <li><a href="javascript:void(0);" class="top-menu-item" id="bookmarkMenuBtn"> <i class="icon-btn-favorite"></i><span>즐겨찾기</span></a>--%>
            </ul>

         </div>
         <!-- /top-menu-right -->
      </div>
      <!-- /top 메뉴 전체 (top-menu-left, top-menu-right) -->
   <!-- /top -->
   </div>

	<!-- 즐겨찾기 팝업 메뉴 -->
	<div class="favorite-menu dpn" id="bookmarkMenu">
		<div class="tri"></div>
		<div class="favorite">
			<div class="favorite-header">
				<div>즐겨찾기</div>
				<div>
					<button type="button" class="btn btn-outline-default" onclick="javascript:goBookmarkPopup();">설정<i class="material-iconsadd"></i>
					</button>
				</div>
			</div>
			<!-- 즐겨찾기 한 메뉴가 없는 경우 -->
			<div class="no-data text-primary dpn"> <!-- class: dpn으로 노출여부 수정 -->
				자주 방문하는 메뉴를 <br>추가하세요.
			</div>
			<!-- /즐겨찾기 한 메뉴가 없는 경우-->
			<!-- 즐겨찾기 한 페이지에 최대 30개 노출 -->
			<ul class="data" id="bookmarkList"> <!-- class: dpn으로 노출여부 수정 -->
			</ul>
			<!-- /즐겨찾기 한 페이지에 최대 30개 노출 -->
		</div>
	</div>
	<!-- /즐겨찾기 팝업 메뉴 -->

   <!-- left -->
   <div id="left" class="left-wrap" data-options="region:'west', hideExpandTool:true, collapsedSize : 0">
      <div class="layout-left">
         <!-- personal 영역 -->
         <!--  <div class="personal"> -->
         <div class="personal">
            <div class="personal-header">
				<div class="user">
					<c:choose>
						<c:when test="${_apprMemList.size() > 1 }">
							<select class="form-control" name="s_mem_no" id="s_mem_no" style="width: 90px; text-align-last: center;" onchange="javascript:changeMem(this);">
								<c:forEach var="list" items="${_apprMemList}">
									<option value="${list.mem_no}" <c:if test="${list.mem_no eq SecureUser.mem_no}">selected</c:if> >${list.kor_name}</option>
								</c:forEach>
							</select>
						</c:when>
						<c:otherwise>
						<i class="icon-btn-user"></i>
							<strong style="width: 60px; overflow: hidden; white-space: nowrap; text-overflow:ellipsis">${SecureUser.user_name}</strong>
						</c:otherwise>
					</c:choose>
				</div>
				<div class="user-con">
					<!-- <a href="javascript:void(0);" class="target new-note" url="/mmyy/mmyy0102" title="쪽지함">
						<i class="material-iconsmail_outline"></i>
					</a> -->
					<button type="button" class="btn btn-light mr3" onclick="javascript:goPaperRoom()"><i class="material-iconsmail_outline"></i></button>
                    <button type="button" class="btn btn-light mr3" onclick="javascript:fnToggleFavoritLeft();"><i class="icon-btn-favorite-s"></i></button>
					<button type="button" class="btn btn-light" onclick="javascript:goLogout();"><i class="material-iconspower_settings_new"></i></button>
				</div>
			</div>
            <div class="worktime">
               <div class="time-chk">
               		<c:if test= "${timeBean.in_yn eq 'N'}">
                  	<span class="title">출근 하세요!!</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  </c:if>
               	  <c:if test= "${timeBean.in_yn eq 'Y' and timeBean.out_yn ne 'Y'}">
                  	<span class="title">출근</span> <span>${timeBean.in_time }</span>&nbsp;&nbsp;&nbsp;
                  </c:if>
                  <c:if test= "${timeBean.out_yn eq 'Y'}">
                  	<span class="title">출근</span> <span>${timeBean.in_time_short }</span>&nbsp;&nbsp;&nbsp;
                  	<span class="title">퇴근</span> <span>${timeBean.out_time }</span>
                  </c:if>
               </div>
               <button type="button" class="btn btn-light" onclick='javascript:goMyInfo();' ><i class="material-iconsedit"></i></button>
               <c:if test= "${timeBean.in_yn eq 'N'}">
	               <button class="btn btn-light" onclick="javascript:goMemWork('IN');" >출근</button>
               </c:if>
               <c:if test= "${timeBean.in_yn eq 'Y' and timeBean.out_yn eq 'N'}">
	               <button class="btn btn-light" onclick="javascript:goMemWork('OUT');" >퇴근</button>
               </c:if>
            </div>
            <div class="worktime-content">
            	 <c:if test="${SecureUser.org_type ne 'AGENCY'}">
	                 <div class="content">
	                     <a href='javascript:void(0);' url='/mmyy/mmyy0101' title='공지사항' class="count target" id="no_read_notice_cnt">0</a>
	                     <div class="title">미 확인 공지</div>
	                 </div>
                 </c:if>
                 <div class="content">
                     <a href="javascript:goPaperDetail();" class="count" id="no_read_paper_cnt">0</a>
                     <div class="title">안 읽은 쪽지</div>
                 </div>
             </div>
         </div>
         <!-- /personal 영역 -->
         <!-- SNB 영역 -->
         <div class="snb" id="leftMenuArea">
         </div>
         <div class="snb dpn" id="leftFavoritArea">
         </div>
         <!-- /SNB 영역 -->
      </div>
   </div>
   <!-- /left -->
   <!-- contents 전체 영역 -->
   <div class="contents" data-options="region:'center'" data-options="fit:true,border:false">
   <!-- 그리드 타이틀, 컨트롤 영역 -->
   <div class="acco-menu-wrap acco-menu-opened">
		<button type="button" class="icon-btn-cancel btn-accor-menu" id="back_btn"><i class="material-iconsarrow_back_ios font-16 text-default" style="margin-top: -2px;"></i></button>
   </div>
   <!-- content wrap이 들어갈 자리 -->
    <div id="mainContent" class="contents" style="height: 100%"></div>
    <div id="tt" class="easyui-tabs" data-options="tools:'#tab-tools'" style="height: 100%"></div>
		<div id="tab-tools">
			<!-- <button type="button" class="icon-btn-cancel btn-default" style="height: 24px; width: 18px; border-radius: 4px;" id="closeAllTabs"><i class="material-iconsclose font-16 text-default" style="line-height: 20px;"></i></button> -->
			<button type="button" class="icon-btn-cancel btn-accor-menu" id="closeAllTabs"><i class="material-iconsclose font-16 text-default" style="margin-top: -2px;margin-right:1px"></i></button>
		</div>
   </div>
   <!-- /contents 전체 영역 -->
   	<div id="alertDialog"></div>
</body>
</html>
