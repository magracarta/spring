<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 서비스부 업무일지 상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-30 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		/* var tab_id; */
		var auiGridTop;
		var auiGridBottom;
		
		function goLarge(type) {
			var param = {
				s_mem_no : "${inputParam.s_mem_no}",
				s_work_dt : "${inputParam.s_work_dt}",
				s_work_text : type
			}
			var poppupOption = "";
			var url = '/mmyy/mmyy010301p01';
			$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
		}
	
		$(document).ready(function() {
			/* $('ul.tabs-c li a').click(function() {
				tab_id = $(this).attr('data-tab');
	
				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');
	
				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
			}); */
			
			
			//파라미터 못가져오는 경우 리로딩 
			if("${inputParam.s_work_dt}" == "" || "${inputParam.s_yesterday}" == "" || "${inputParam.s_tomorrow}" == "") {
				location.reload();
			}
			
			createAUIGridTop();
			createAUIGridBottom();
			
			$("#btnHide").children().eq(0).attr('id','btnComplete');
			$("#btnHide").children().eq(1).attr('id','btnCancel');
			$("#btnHide").children().eq(2).attr('id','btnSave');
			
	
			if("${inputParam.s_mem_no}" ==  '${SecureUser.mem_no}'){
			
				if("${bean.complete_yn}" == "Y"){
					
					$("#btnComplete,#btnSave").css({
			            display: "none"
			        });
					
					if("${cancel_yn}" == "N"){
						$("#btnCancel").css({
				            display: "none"
				        });
					}					
				}
				else if("${save_yn}" == "Y"){
					$("#btnCancel").css({
			            display: "none"
			        });
				}
				else{
					$("#btnComplete,#btnSave,#btnCancel").css({
			            display: "none"
			        });
				}
			}
			else {
				$("#btnComplete,#btnSave,#btnCancel").css({
		            display: "none"
		        });
			}
			
			$(".editor").on("keypress", function(e) {
			      e.preventDefault();
			});
			
			goSearchTodayAs();
			goSearchCnts();
		});
		
		function goSearchTodayAs() {
			var param = {
				s_mem_no : "${inputParam.s_mem_no}", 
				s_work_dt : "${inputParam.s_work_dt}",
			}
			AUIGrid.showAjaxLoader(auiGridTop);
			$M.goNextPageAjax("/mmyy/mmyy0103p01/search", $M.toGetParam(param), {method : 'get', loader : false},
				function(result) {
					AUIGrid.removeAjaxLoader(auiGridTop);
					if(result.success) {
						AUIGrid.setGridData(auiGridTop, result.list);
					};
				}
			); 
		}
		
		function goSearchCnts() {
      var arr = ["todayCnt", "cmpCnt", "servCnt", "diCnt", "endCnt", "happyCnt", "capCnt", "periodCnt", "phoneCnt"];
			var param = {
				s_mem_no : "${inputParam.s_mem_no}", 
				s_work_dt : "${inputParam.s_work_dt}",
			}
      
			$M.goNextPageAjax("/mmyy/mmyy0103p01/cnt", $M.toGetParam(param), {method : 'get', loader : false},
				function(result) {
					if(result.success) {
						for (var i = 0; i <arr.length; ++i) {
							var temp = $("#"+arr[i]);
							temp.addClass("work_daily_a_link link-bracket");
							console.log(result[arr[i]]);
							temp.html(result[arr[i]]);
						}
					};
				}
			); 
      
		}
		
		function createAUIGridTop() {
			var gridPros = {
					showRowNumColumn : false
				}
		
				var columnLayout = [
					{
						dataField : "as_no",
						visible : false
					},
					{
						dataField : "as_type_name",
						visible : false
					},
					{
						headerText  : "정비시간",
						dataField : "item_time",
						width : "17%",
						style : "aui-center",
					},
					{
						headerText : "고객명",
						dataField : "cust_name",
						width : "17%",
						style : "aui-center"
					},
					{
						headerText : "모델명",
						dataField : "machine_name",
						width : "17%",
						style : "aui-center"
					},
					{
						headerText : "정비",
						dataField : "item_data",
						style : "aui-left aui-popup"
					}
				];
		
				auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
				AUIGrid.setGridData(auiGridTop, []);
				
				AUIGrid.bind(auiGridTop, "cellClick", function(event) {
					if(event.dataField == "item_data" ) {
						if(event.item.as_type_name == "전화상담" ) {
							var params = {
								"s_as_no" : event.item.as_no
							};

							var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=820, left=0, top=0";
							$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus : popupOption});
						} else if(event.item.as_type_name == "정비일지") {
							var params = {
								"s_as_no" : event.item.as_no
							};

							var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
							$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus : popupOption});
						} else if(event.item.as_type_name == "출하일지") {
							var params = {
								"s_as_no" : event.item.as_no
							};

							var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
							$M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus : popupOption});
						}
					}
				});
		}
		
		function createAUIGridBottom() {
			var gridPros = {
					showRowNumColumn : true
				}
		
				var columnLayout = [
					{
						headerText  : "사원명",
						dataField : "mem_name",
						width : "15%",
						style : "aui-center"
					},
					{
						headerText : "구분",
						dataField : "holiday_type_name",
						width : "15%",
						style : "aui-center"
					},
					{
						headerText : "일정기간",
						dataField : "schedule_term",
						width : "30%",
						style : "aui-center"
					},
					{
						headerText : "내용",
						dataField : "content",
						style : "aui-left" 
					}
				];
		
		
				auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
				AUIGrid.setGridData(auiGridBottom, listJson);
		}
	
		function goSearch(type) {
			// 여러번 눌리는걸 방지하기 위해 버튼 disable
			$(':button').attr('disabled', true);
			var s_work_dt = (type == 'pre' ? '${inputParam.s_yesterday}' : '${inputParam.s_tomorrow}');
			var param = {
					"s_mem_no"  :  "${inputParam.s_mem_no}",
					"s_work_dt"   :  s_work_dt
				};	
			$M.goNextPage(this_page, $M.toGetParam(param));
		}
		

		
		function goComplete() {			
			
			var frm = document.main_form;
			
			 // validation check
	     	if($M.validation(frm) == false) {
	     		return;
	     	}
			
			//console.log($M.toValueForm(frm));
			//console.log(frm);
			$M.goNextPageAjaxMsg("일지작성을 마감하시겠습니까?","/work/savecomplete", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
		}
		
		
		function goSave() {			
			
			var frm = document.main_form;			
			console.log($M.toValueForm(frm));
			console.log(frm);
			
			 // validation check
	     	if($M.validation(frm) == false) {
	     		return;
	     	}
			
			$M.goNextPageAjaxSave("/work/save", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
		}
		
	
		
		function fnCancel() {			
			
			var frm = document.main_form;
			
			//console.log($M.toValueForm(frm));
			//console.log(frm);
			$M.goNextPageAjaxMsg("일지작성완료 취소하시겠습니까?","/work/cancel", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
		}
		
		function fnClose() {
			window.close();
		}
		
		function goPaper() {
			var menuName = "";
			var dt = $M.getValue("s_work_dt");
			
			menuName += "${inputParam.s_mem_name}님의 "
			menuName += dt.replace(/(\d{4})(\d{2})(\d{2})/g, '$1-$2-$3');
			menuName += " 업무일지에서 보낸쪽지입니다.#";
			menuName += "자료조회로 내용을 참고하세요.#"
			menuName += "#";
			var jsonObject = {
				"paper_contents" : menuName,
				"receiver_mem_no_str" : "${inputParam.s_mem_no}",	// 수신자
				"refer_mem_no_str" : "",		// 참조자
				"menu_seq" : "${page.menu_seq}",
				"pop_get_param" : "s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}",
				"cmd" : "N"
			}
	    	openSendPaperPanel(jsonObject);
		}

    function goPageOpen(strType) {
      var popupOption = "";

      if ($M.getValue("s_work_dt") == "") {
        alert("잠시후 다시 시도해주세요.");
        location.reload();
      } else {
        switch (strType) {
          case "service" : // 당일 정비
            $M.goNextPage('/serv/serv0102', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "toDo1" :  // 전산미결
            $M.goNextPage('/serv/serv0403', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "toDo" : // 서비스미결
            $M.goNextPage('/serv/serv0402', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "diCall" : // DI Call
            $M.goNextPage('/serv/serv040402', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "endCall" : // 종료점검 Call
            $M.goNextPage('/serv/serv040403', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "happyCall" :  // Happy Call
            $M.goNextPage('/serv/serv040404', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "capCall" :  // CAP Call
            $M.goNextPage('/serv/serv040407', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "cycleCall" :  // 정기검사 Call
            $M.goNextPage('/serv/serv040406', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "misuCall" :  // 미수금 Call
            $M.goNextPage('/serv/serv040405', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
          case "asCall" :  // 전화상담
            $M.goNextPage('/serv/serv0102', $M.toGetParam(getGoPageParam(strType)), {popupStatus: popupOption});
            break;
        }
      }
    }
    
        function getGoPageParam(strType) {
          var param = {
            "s_start_dt" :  $M.getValue("s_work_dt"),
            "s_end_dt"  :   $M.getValue("s_work_dt"),
            "s_work_dt" :  $M.getValue("s_work_dt"),
            "s_work_gubun" : "Y"
          };

          if($M.getValue("s_work_dt") == "" ){
            alert("잠시후 다시 시도해주세요.");
            location.reload();
          } else {
            switch (strType) {
              case "service" : // 당일 정비
                param.s_mem_no = "${inputParam.s_mem_no}";
                param.org_type = "${inputParam.s_mem_org_gubun}";
                param.login_org_code = "${inputParam.s_mem_org_code}";
                param.s_as_type_str = "R#O";		//여러상태를 조회할때는 언더바로 구분자로 보내기로 처리 ( 2020-12-19 )
                param.s_appr_proc_status_cd_str = "03#05";
                param.s_page_type = "work";
                break;
              case "toDo1" :  // 전산미결
                param.login_mem_no = "${inputParam.s_mem_no}";
                param.s_page_type = "work";
                break;
              case "toDo" : // 서비스미결
                param.s_as_todo_status = "0";
                <c:if test="${inputParam.s_mem_org_gubun eq 'CENTER'}" >
                  param.s_org_code = "${inputParam.s_mem_org_code}";
                </c:if>
                break;
              case "diCall" : // DI Call
                param.login_org_code = "${inputParam.s_mem_org_code}";
                break;
              case "endCall" : // 종료점검 Call
                param.login_org_code = "${inputParam.s_mem_org_code}";
                break;
              case "happyCall" :  // Happy Call
                param.login_org_code = "${inputParam.s_mem_org_code}";
                break;
              case "capCall" :  // CAP Call
              <c:if test="${inputParam.s_mem_org_gubun eq 'CENTER'}" >
                //param.s_service_mem_no = "${inputParam.s_mem_no}";
                param.s_org_code = "${inputParam.s_mem_org_code}";
              </c:if>
                break;
              case "cycleCall" :  // 정기검사 Call
                param.login_org_code = "${inputParam.s_mem_org_code}";
                break;
              case "misuCall" :  // 미수금 Call
                param.login_org_code = "${inputParam.s_mem_org_code}";
                break;
              case "asCall" :  // 전화상담
                param.s_mem_no = "${inputParam.s_mem_no}";
                param.org_type = "${inputParam.s_mem_org_gubun}";
                param.login_org_code = "${inputParam.s_mem_org_code}";
                param.s_as_type_str = "C";		//여러상태를 조회할때는 언더바로 구분자로 보내기로 처리 ( 2020-12-19 )
                param.s_appr_proc_status_cd_str = "03#05";
                param.s_page_type = "work";
                break;
            }
          }
          
          
          return param;
        }

    </script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
      <div class="popup-wrap width-100per">
          <!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
          <!-- /타이틀영역 -->
          	<div class="content-wrap">  	
          		<input type="hidden" id="work_dt" name="work_dt" value="${inputParam.s_work_dt}"  > 
          		<input type="hidden" id="work_diary_seq" name="work_diary_seq" value="${bean.work_diary_seq}"  >
          		
          		<div>
                  <div class="title-wrap">
                      <div class="left">
                          <h4><span class="text-primary">${inputParam.s_org_name} ${inputParam.s_mem_name}</span>님 업무일지</h4>
                      </div>
                      <div class="right">근무시간기준 : <span>08:30 ~ 18:00</span></div>
                  </div>
                  <!-- 검색영역 -->
                  <div class="search-wrap mt5 boder-bottom-sq">
                      <table class="table">
                          <colgroup>
                              <col width="28px" />
                              <col width="100px" />
                              <col width="50px" />
                              <col width="" />
                          </colgroup>
                          <tbody>
                              <tr>
                                  <td>
                                      <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('pre');"  ><i class="material-iconsarrow_left"></i></button>
                                  </td>
                                  <td>
                                      <input type="text" class="form-control text-center" readonly="readonly" id="s_work_dt" name="s_work_dt" value="${inputParam.s_work_dt}" dateformat="yyyy-MM-dd"/>
                                  </td>
                                  <td>
                                      <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('next');" ><i class="material-iconsarrow_right"></i></button>
                                  </td>
			 					  <td>
										${inputParam.s_dayofweek} ${inputParam.s_schedule != '' ? '[' : '' }<span class="text-primary">${inputParam.s_schedule}</span>${inputParam.s_schedule != '' ? ']' : '' }
										<button type="button" class="btn btn-default" onclick="javascript:goPaper()">쪽지</button>
								  </td>                                 
                                  <td class="text-right search-info-journal">
                                      <span>
                                          업무시작 :
                                          <span>${beanlog.login_date}</span>
                                      </span>
                                      <span>
                                          업무종료 :
                                          <span>${bean.complete_date}</span>
                                      </span>
                                  </td>
                              </tr>
                          </tbody>
                      </table>
                  </div>
                  <!-- /검색영역 -->
                  <!-- 상세내용 -->
                  <div class="">
                      <div class="tabs-inner-line">
                          <div class="boxing bd0 pd0 vertical-line mt5">
                              <span>
                                  <span class="bd0 pr5">당일정비</span>
                                  <a class="" href="#" onclick="javascript:goPageOpen('service');" id="todayCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                              <span>
                                  <span class="bd0 pr5">전산미결</span>
                                  <a  href="#" onclick="javascript:goPageOpen('toDo1');" id="cmpCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                              <span>
                                  <span class="bd0 pr5">서비스미결</span>
                                  <a  href="#" onclick="javascript:goPageOpen('toDo');" id="servCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                              <span>
                                  <span class="bd0 pr5">DI Call</span>
                                  <a  href="#" onclick="javascript:goPageOpen('diCall');" id="diCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                              <span>
                                  <span class="bd0 pr5">종료점검 Call</span>
                                  <a  href="#" onclick="javascript:goPageOpen('endCall');" id="endCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                              <span>
                                  <span class="bd0 pr5">Happy Call</span>
                                  <a  href="#" onclick="javascript:goPageOpen('happyCall');" id="happyCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                              <span>
                                  <span class="bd0 pr5">CAP Call</span>
                                  <a  href="#" onclick="javascript:goPageOpen('capCall');" id="capCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                              <span>
                                  <span class="bd0 pr5">정기검사 Call</span>
                                  <a  href="#" onclick="javascript:goPageOpen('cycleCall');" id="periodCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
<%--                              <span>--%>
<%--                                  <span class="bd0 pr5">미수금Call</span>--%>
<%--                                  <a class="work_daily_a_link link-bracket" href="#" onclick="javascript:goPageOpen('misuCall');">${misuCallListSize}</a>--%>
<%--                              </span>--%>
                              <span class="bd0">
                                  <span class="bd0 pr5">전화상담</span>
                                  <a  href="#" onclick="javascript:goPageOpen('asCall');" id="phoneCnt">
                                  	<div class="cntloader"></div>
                                  </a>
                              </span>
                          </div>
                      </div>
                  </div>
                  <!-- /상세내용 -->
                  <div class="row">
                      <div class="col-5">
                          <!-- 금일정비현황 -->
                          <div class="title-wrap mt10">
                              <h4>금일정비현황</h4>
                          </div>
                          <div id="auiGridTop"  style="margin-top: 5px; height: 300px;" ></div>
                          <!-- /금일정비현황 -->
                          <!-- 내일 인사일정 -->
                          <div class="title-wrap mt10">
                              <h4>내일 인사일정</h4>
                          </div>
                          <div id="auiGridBottom" style="margin-top: 5px; height: 200px;"></div>
                          <!-- /내일 인사일정 -->
                      </div>
                      <div class="col-7">
                          <!-- 금일업무계획 -->
                          <div class="title-wrap mt10">
                              <h4>금일업무계획(가장 최근에 작성한 내일업무계획)</h4>
                              <!-- <button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('prev')">크게보기</button> -->
                          </div>
                          <c:choose>
		                    	<c:when test="${fn:contains(beanprev.prev_work_text, '</p>') || fn:contains(beanprev.prev_work_text, '</span>') || fn:contains(beanprev.prev_work_text, '</div>')}">
		                    		<div contenteditable="true" style="height: 115px; overflow-y: scroll;" class="form-control mt5 editor">${beanprev.prev_work_text}</div>
		                    	</c:when>
		                    	<c:otherwise>
		                    		<textarea class="form-control mt5" style="height: 115px;"  id="prev_work_text" name="prev_work_text" readonly="readonly" >${beanprev.prev_work_text}</textarea>
		                    	</c:otherwise>
		                    </c:choose>
                          <!-- /금일업무계획 -->
                          <!-- 금일업무내용 -->
                          <div class="title-wrap mt10">
                              <h4>금일업무내용</h4>
                              <button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('today')">크게보기</button>
                          </div>
                          <c:choose>
		                    	<c:when test="${fn:contains(bean.work_text, '</p>') || fn:contains(bean.work_text, '</span>') || fn:contains(bean.work_text, '</div>')}">
		                    		<div contenteditable="true" style="height: 230px; overflow-y: scroll;" class="form-control mt5 editor">${bean.work_text}</div>
		                    	</c:when>
		                    	<c:otherwise>
		                    		<textarea class="form-control mt5" style="height: 230px;" id="work_text" name="work_text" required="required" alt="당일특이사항" >${ bean.work_text}</textarea>
		                    	</c:otherwise>
		                    </c:choose>
                          <!-- /금일업무내용 -->
                          <!-- 내일업무계획 -->
                          <div class="title-wrap mt10">
                              <h4>내일업무계획</h4>
                              <!-- <button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('next')">크게보기</button> -->
                          </div>
                          <c:choose>
		                    	<c:when test="${fn:contains(bean.next_work_text, '</p>') || fn:contains(bean.next_work_text, '</span>') ||  fn:contains(bean.next_work_text, '</div>')}">
		                    		<div contenteditable="true" style="height: 115px; overflow-y: scroll;" class="form-control mt5 editor">${bean.next_work_text}</div>
		                    	</c:when>
		                    	<c:otherwise>
		                    		<textarea class="form-control mt5" style="height: 115px;" id="next_work_text" name="next_work_text"  >${bean.next_work_text}</textarea>
		                    	</c:otherwise>
		                    </c:choose>
                          <!-- /내일업무계획 -->
                      </div>
                  </div>
                  <div class="btn-group mt10">
						<div class="right" id="btnHide"  >
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
                  </div>
              </div>
          </div>
      </div>
      <!-- /팝업 -->
</form>
</body>
</html>