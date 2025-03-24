<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 관리부 업무일지 상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-30 13:11:05
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>

		var tab_id;
		var auiGridTop;
		var auiGridBottom;

		var isLoading1 = false;
		var isLoading2 = false;
		var isLoading3 = false;
		var isLoading4 = false;
		var isLoading5 = false;

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

		var auiGridIds = {
			PASSBOOK : "auiGridinner1",
			INOUTDOC : "auiGridinner2",
			TAXBILL : "auiGridinner3",
			CARDUSE : "auiGridinner4",
			ACCOUNT : "auiGridinner5"
		}

		$(document).ready(function() {

			createauiGridinner1();
			createauiGridinner2();
			createauiGridinner3();
			createauiGridinner4();
			createauiGridinner5();

			$('ul.tabs-c li a').click(function() {
				tab_id = $(this).attr('data-tab');

				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');

				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
				$("#"+auiGridIds[tab_id]).resize();
				goSearchTab(tab_id);
			});

			goSearchTab("PASSBOOK");

			//파라미터 못가져오는 경우 리로딩
			if("${inputParam.s_work_dt}" == "" || "${inputParam.s_yesterday}" == "" || "${inputParam.s_tomorrow}" == "") {
				location.reload();
			}

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
		});

		function goSearchTab(id) {
			// IE ERROR 대응하기위해 다시 새로운 변수에 할당
			var tabId = id;
			var processable = true;
			switch (tabId) {
				case "PASSBOOK":
					isLoading1 == true ? processable = false : isLoading1 = true;
				break;
				case "INOUTDOC":
					isLoading2 == true ? processable = false : isLoading2 = true;
				break;
				case "TAXBILL":
					isLoading3 == true ? processable = false : isLoading3 = true;
				break;
				case "CARDUSE":
					isLoading4 == true ? processable = false : isLoading4 = true;
				break;
				case "ACCOUNT":
					isLoading5 == true ? processable = false : isLoading5 = true;
				break;
			}
			if (processable == false) {
				return false;
			}
			var param = {
				s_mem_no : "${inputParam.s_mem_no}",
				s_work_dt : "${inputParam.s_work_dt}",
			}
			// console.log("#"+auiGridIds[tabId]);
			AUIGrid.showAjaxLoader("#"+auiGridIds[tabId]);
			$M.goNextPageAjax("/mmyy/mmyy0103p03/"+tabId, $M.toGetParam(param), {method : 'get', loader : false},
				function(result) {
					AUIGrid.removeAjaxLoader("#"+auiGridIds[tabId]);
					if(result.success) {
						AUIGrid.setGridData("#"+auiGridIds[tabId], result.list);
					};
				}
			);
		}

		function createAUIGridBottom() {
			var gridPros = {
					showRowNumColumn : true
				}

				var columnLayout = [
					{
						headerText  : "사원명",
						dataField : "mem_name"
					},
					{
						headerText : "구분",
						dataField : "holiday_type_name",
						width : "15%"
					},
					{
						headerText : "일정기간",
						dataField : "schedule_term",
							width : "30%"
					},
					{
						headerText : "내용",
						dataField : "content",
							width : "30%"
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
			// console.log($M.toValueForm(frm));
			// console.log(frm);

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

	</script>
</head>
<body class="bg-white"  >
<form id="main_form" name="main_form">
<!-- 팝업 -->
      <div class="popup-wrap width-100per">
          <!-- 타이틀영역 -->
          <div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
          </div>
          <!-- /타이틀영역 -->
          <div class="content-wrap">
          		<input type="hidden" id="work_diary_seq" name="work_diary_seq" value="${bean.work_diary_seq}"  >
          		<input type="hidden" id="work_dt" name="work_dt" value="${inputParam.s_work_dt}"  >
              	<div>
	                  <div class="title-wrap">
	                      <div class="left">
	                          <h4><span class="text-primary">${inputParam.s_mem_name}</span>님 업무일지</h4>
	                      </div>
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
	                                      <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('pre');" ><i class="material-iconsarrow_left"></i></button>
	                                  </td>
	                                  <td>
	                                      <input type="text" class="form-control text-center" readonly="readonly" value="${fn:substring(inputParam.s_work_dt,0,4)}-${fn:substring(inputParam.s_work_dt,4,6)}-${fn:substring(inputParam.s_work_dt,6,8)}">
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
	                                          <span>${beanlog.logout_date}</span>
	                                      </span>
	                                  </td>
	                              </tr>
	                          </tbody>
	                      </table>
	                  </div>
	                  <!-- /검색영역 -->
	                  <div class="title-wrap mt10 mr15">
	                      <h4>금일진행현황</h4>
	                  </div>
	                  <!-- 탭 -->
	                  <ul class="tabs-c mt5" style="flex-grow: 1;">
	                      <li class="tabs-item">
	                          <a href="#" class="tabs-link font-12 active" data-tab="PASSBOOK" >계좌입출금</a>
	                      </li>
	                      <li class="tabs-item">
	                          <a href="#" class="tabs-link font-12" data-tab="INOUTDOC" >일계표</a>
	                      </li>
	                      <li class="tabs-item">
	                          <a href="#" class="tabs-link font-12" data-tab="TAXBILL" >세금계산서</a>
	                      </li>
	                      <li class="tabs-item">
	                          <a href="#" class="tabs-link font-12" data-tab="CARDUSE" >법인카드</a>
	                      </li>
	                      <li class="tabs-item">
	                          <a href="#" class="tabs-link font-12" data-tab="ACCOUNT" >금전출납부</a>
	                      </li>
	                  </ul>
	                  <!-- /탭 -->

					<!-- /메인 타이틀 -->
					<div id="PASSBOOK" class="tabs-inner active">
						<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0301.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
					</div>
					<div id="INOUTDOC" class="tabs-inner">
						<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0302.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
						</div>
					<div id="TAXBILL" class="tabs-inner">
						<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0303.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
					</div>
					<div id="CARDUSE" class="tabs-inner">
						<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0304.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
					</div>
					<div id="ACCOUNT" class="tabs-inner">
						<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0305.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
					</div>
		            <div class="row">
		                <div class="col-7">
		                    <!-- 전일미결사항 -->
		                    <div class="title-wrap mt10">
		                        <h4>전일미결사항(가장 최근에 작성한 미결사항)</h4>
		                        <!-- <button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('pre')">크게보기</button> -->
		                    </div>
		                    <c:choose>
		                    	<c:when test="${fn:contains(beanprev.prev_work_text, '</p>') || fn:contains(beanprev.prev_work_text, '</span>') || fn:contains(beanprev.prev_work_text, '</div>')}">
		                    		<div contenteditable="true" style="height: 150px; overflow-y: scroll;" class="form-control mt5 editor">${beanprev.prev_work_text}</div>
		                    	</c:when>
		                    	<c:otherwise>
		                    		<textarea class="form-control mt5" style="height: 70px;"  id="prev_work_text" name="prev_work_text" readonly="readonly" >${beanprev.prev_work_text}</textarea>
		                    	</c:otherwise>
		                    </c:choose>
		                    <!-- /전일미결사항 -->
		                    <!-- 당일특이사항 -->
		                    <div class="title-wrap mt10">
		                        <h4>당일특이사항</h4>
		                        <button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('today')">크게보기</button>
		                    </div>
		                    <c:choose>
		                    	<c:when test="${fn:contains(bean.work_text, '</p>') || fn:contains(bean.work_text, '</span>') || fn:contains(bean.work_text, '</div>')}">
		                    		<div contenteditable="true" style="height: 150px; overflow-y: scroll;" class="form-control mt5 editor">${bean.work_text}</div>
		                    	</c:when>
		                    	<c:otherwise>
		                    		<textarea class="form-control mt5" style="height: 150px;" id="work_text" name="work_text" required="required" alt="당일특이사항" >${bean.work_text}</textarea>
		                    	</c:otherwise>
		                    </c:choose>
		                    <!-- /당일특이사항 -->
		                    <!-- 당일미결사항 -->
		                    <div class="title-wrap mt10">
		                        <h4>당일미결사항</h4>
		                        <!-- <button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('next')">크게보기</button> -->
		                    </div>
		                    <c:choose>
		                    	<c:when test="${fn:contains(bean.next_work_text, '</p>') || fn:contains(bean.next_work_text, '</span>') ||  fn:contains(bean.next_work_text, '</div>')}">
		                    		<div contenteditable="true" style="height: 150px; overflow-y: scroll;" class="form-control mt5 editor">${bean.next_work_text}</div>
		                    	</c:when>
		                    	<c:otherwise>
		                    		<textarea class="form-control mt5" style="height: 70px;" id="next_work_text" name="next_work_text"  >${bean.next_work_text}</textarea>
		                    	</c:otherwise>
		                    </c:choose>
		                    <!-- /당일미결사항 -->
		                </div>
		                <div class="col-5">
		                    <!-- 내일 인사일정 -->
		                    <div class="title-wrap mt10">
		                        <h4>내일 인사일정</h4>
		                    </div>
		                    <div id="auiGridBottom" style="margin-top: 5px; height: 370px;"></div>
		                    <!-- /내일 인사일정 -->
		                </div>
		            </div>
	               	<div class="btn-group mt10">
						<div class="right" id="btnHide" >
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
