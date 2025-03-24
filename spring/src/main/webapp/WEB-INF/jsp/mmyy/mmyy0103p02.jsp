<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업부 업무일지 상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-20 14:31:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/SmartEditor/js/HuskyEZCreator.js" charset="utf-8"></script>
	<script type="text/javascript">
		var tab_id;
		var auiGridTop;
		var auiGridBottom;
		
		var isLoading1 = false;
		var isLoading2 = false;
		var isLoading3 = false;
		var isLoading4 = false;
		var isLoading5 = false;
		var isLoading6 = false;

		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 5;
		
		function goConsultAll() {
			var param = {
				s_mem_no : "${inputParam.s_mem_no}",
				s_work_dt : "${inputParam.s_work_dt}"
			}
			var poppupOption = "";
			var url = '/mmyy/mmyy010301p02';
			$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
		}

		function goAddConsult() {
			var poppupOption = "";
			var params = {};
			$M.goNextPage('/cust/cust0101p05', $M.toGetParam(params), {popupStatus: poppupOption});
		}
		
		var auiGridIds = {
			CUSTCONSULT : "auiGridinner1",
			DOC : "auiGridinner2",
			DOCAPPR : "auiGridinner3",
			OUTDOCAPPR : "auiGridinner4",
			DEPOSITRESULT : "auiGridinner5",
			MACHINELC : "auiGridinner6"
		}
		
		function goLarge(type) {
			var param = {
				s_mem_no : "${inputParam.s_mem_no}",
				s_work_dt : "${inputParam.s_work_dt}",
				s_type : type
			}
			var poppupOption = "";
			var url = '/mmyy/mmyy010301p01';
			$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
		}
	
		$(document).ready(function() {
			
			createauiGridinner1();
			createauiGridinner2();
			// 신정애사원님 대행으로 이금님사원님 권한(2902)추가.  210602 김상덕
			<c:if test="${page.fnc.F00623_001 eq 'Y'}">
			createauiGridinner3();
			createauiGridinner4();
			createauiGridinner5();
			createauiGridinner6();
			</c:if>

			$('ul.tabs-c li a').click(function() {
				tab_id = $(this).attr('data-tab');

				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');

				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
				$("#"+auiGridIds[tab_id]).resize();
				goSearchTab(tab_id);
			});
			
			goSearchTab("CUSTCONSULT");
						
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

			<c:forEach var="list" items="${fileList}">fnPrintFile('${list.file_seq}', '${list.file_name}');</c:forEach>
	
		});
		
		function goSearchTab(id) {
			// IE ERROR 대응하기위해 다시 새로운 변수에 할당
			var tabId = id;
			var processable = true;
			switch (tabId) {
				case "CUSTCONSULT": 
					isLoading1 == true ? processable = false : isLoading1 = true;
				break;
				case "DOC":
					isLoading2 == true ? processable = false : isLoading2 = true;
				break;
				case "DOCAPPR":
					isLoading3 == true ? processable = false : isLoading3 = true;
				break;
				case "OUTDOCAPPR":
					isLoading4 == true ? processable = false : isLoading4 = true;
				break;
				case "DEPOSITRESULT":
					isLoading5 == true ? processable = false : isLoading5 = true;
				break;
				case "MACHINELC":
					isLoading6 == true ? processable = false : isLoading6 = true;
				break;
			} 
			if (processable == false) {
				return false;
			}
			var param = {
				s_mem_no : "${inputParam.s_mem_no}", 
				s_work_dt : "${inputParam.s_work_dt}",
			}
			console.log("#"+auiGridIds[tabId]);
			AUIGrid.showAjaxLoader("#"+auiGridIds[tabId]);
			$M.goNextPageAjax("/mmyy/mmyy0103p02/"+tabId, $M.toGetParam(param), {method : 'get', loader : false},
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
						dataField : "mem_name",
						width : "11%"
					},
					{
						headerText : "구분",
						dataField : "holiday_type_name",
						width : "13%"
					},
					{
						headerText : "일정기간",
						dataField : "schedule_term",
						width : "35%"
					},
					{
						headerText : "내용",
						dataField : "content",
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
			editSet();
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
			if (confirm("저장하시겠습니까?") == false) {
				return false;
			}

			var idx = 1;
			$("input[name='file_seq']").each(function() {
				var str = 'work_file_seq_' + idx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			for(; idx <= fileCount; idx++) {
				$M.setValue('work_file_seq_' + idx, 0);
			}

			var frm = document.main_form;	
			editSet();

			// validation check
			if($M.validation(frm) == false) {
				return;
			}

			$M.goNextPageAjax("/work/save", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
		}
		
		// 에디터 내용 갱신
		function editSet() {
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
 			$M.setValue("work_text", $M.getValue("ir1"));
		}
		
	
		
		function fnCancel() {			
			
			var frm = document.main_form;
			
			//console.log($M.toValueForm(frm));
			//console.log(frm);
			
			 // validation check
	     	if($M.validation(frm) == false) {
	     		return;
	     	}
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
		
		
		
		// 에디터 관련 start
		function pasteHTML() {
			var sHTML = "<span style='color:#FF0000;'>이미지도 같은 방식으로 삽입합니다.<\/span>";
			oEditors.getById["ir1"].exec("PASTE_HTML", [ sHTML ]);
			oEditors2.getById["ir2"].exec("PASTE_HTML", [ sHTML ]);
		}

		function submitContents(elClickedObj) {
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []); // 에디터의 내용이 textarea에 적용됩니다.
			oEditors2.getById["ir2"].exec("UPDATE_CONTENTS_FIELD", []); // 에디터의 내용이 textarea에 적용됩니다.

			// 에디터의 내용에 대한 값 검증은 이곳에서 document.getElementById("ir1").value를 이용해서 처리하면 됩니다.

			try {
				elClickedObj.form.submit();
			} catch (e) {
			}
		}

		function setDefaultFont() {
			var sDefaultFont = '궁서';
			var nFontSize = 24;
			oEditors.getById["ir1"].setDefaultFont(sDefaultFont, nFontSize);
			oEditors2.getById["i21"].setDefaultFont(sDefaultFont, nFontSize);
		}

		// 특수문자
		function GetChar(str) {
			addChar(str, 1);
		}
		function addChar(str, type) {
			document.regForm.diaryText.value = document.regForm.diaryText.value
					+ str;
			document.regForm.diaryText.focus();
		}
		function ck(tar) {
			if (tar == "1") {
				document.getElementById("table1").style.display = "block";
			} else if (tar == "2") {
				document.getElementById("table1").style.display = "none";
			}
		}
		// 에디터 관련 end

		// 파일추가
		function fnAddFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

			var fileSeqArr = [];
			var fileSeqStr = "";
			$("[name=file_seq]").each(function() {
				fileSeqArr.push($(this).val());
			});

			fileSeqStr = $M.getArrStr(fileSeqArr);

			var fileParam = "";
			if("" != fileSeqStr) {
				fileParam = '&file_seq_str='+fileSeqStr;
			}

			openFileUploadMultiPanel('setFileInfo', 'upload_type=WORK&file_type=both&total_max_count=5'+fileParam);
		}

		// 첨부파일 출력 (멀티)
		function fnPrintFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item work_file_' + fileIndex + ' fileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.work_file_div').append(str);
			fileIndex++;
		}

		// 파일세팅
		function setFileInfo(result) {
			$(".fileDiv").remove(); // 파일영역 초기화

			var fileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < fileList.length; i++) {
				fnPrintFile(fileList[i].file_seq, fileList[i].file_name);
			}
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".work_file_" + fileIndex).remove();
			} else {
				return false;
			}
		}

		// 첨부서류 일괄다운로드
		function fnFileAllDownload() {
			var fileSeqArr = [];
			$("[name=file_seq]").each(function () {
				fileSeqArr.push($(this).val());
			});

			var paramObj = {
				'file_seq_str' : $M.getArrStr(fileSeqArr)
			}

			fileDownloadZip(paramObj);
		}

		// 타사장비 판매가 등록 팝업 호출
		function goAddCompetiorPrice() {
			$M.goNextPage("/sale/sale0409p01", "", {popupStatus : ""});
		}
	</script>
</head>
<body class="bg-white" >
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
		<!-- 업무일지 -->
		<div>
			<div class="title-wrap">
				<div class="left">
					<h4><span class="text-primary">${inputParam.s_mem_name}</span>님 업무일지</h4>
				</div>
			</div>
			<!-- 검색영역 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="28px">
						<col width="100px">
						<col width="50px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<td>
							<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('pre');" ><i class="material-iconsarrow_left"></i></button>
						</td>
						<td>
							<input type="text" class="form-control text-center" readonly="readonly" value="${fn:substring(inputParam.s_work_dt,0,4)}-${fn:substring(inputParam.s_work_dt,4,6)}-${fn:substring(inputParam.s_work_dt,6,8)}" >
						</td>

						<td>
							<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('next');"><i class="material-iconsarrow_right"></i></button>
						</td>
						<td>
							${inputParam.s_dayofweek} ${inputParam.s_schedule != '' ? '[' : '' }<span class="text-primary">${inputParam.s_schedule}</span>${inputParam.s_schedule != '' ? ']' : '' }
							<button type="button" class="btn btn-default" onclick="javascript:goPaper()">쪽지</button>
						</td>
						<td class="text-right search-info-journal">
							<span>
								로그인 :
								<span>${beanlog.login_date}</span>
							</span>
							<span>
								일지작성완료 :
								<span>${bean.complete_date}</span>
							</span>
							<span>
								로그아웃 :
								<span>${beanlog.logout_date}</span>
							</span>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색영역 -->
		</div>
		<!-- /업무일지 -->
		<div class="contents">
			<div class="title-wrap mt10">
				<h4>금일진행현황</h4>
			</div>
			<ul class="tabs-c">
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12 active"  data-tab="CUSTCONSULT">마케팅대상고객</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12"  data-tab="DOC">계약품의서</a>
				</li>
				<!-- 신정애사원님 대행으로 이금님사원님 권한(2902)추가.  210602 김상덕 -->
				<c:if test="${page.fnc.F00623_001 eq 'Y'}">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="DOCAPPR">계약품의서결재</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="OUTDOCAPPR">출하의뢰서결재</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="DEPOSITRESULT" title="입금처리한 날짜 기준">입금처리</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="MACHINELC">장비입고-LC</a>
					</li>
				</c:if>	
				<li style="padding-bottom: 0;line-height: 2;padding-left: 5px;padding-top: 3px;">
					<div style="line-height: 2;">
						<button type="button" class="btn btn-default" onclick="javascript:goConsultAll()">안건상담 전체보기</button>
						<button type="button" class="btn btn-default" onclick="javascript:goAddConsult()">안건상담 등록</button>
					</div>
				</li>
			</ul>
			<!-- /탭 -->

			<!-- /메인 타이틀 -->
			<div id="CUSTCONSULT" class="tabs-inner active"  style="height: 300px;"> 		
				<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0201.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>			
			</div>
			<div id="DOC" class="tabs-inner" style="height: 300px;" >
				<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0202.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>	
			</div>
			<div id="DOCAPPR" class="tabs-inner " style="height: 300px;"  >
				<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0203.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
			</div>
			<div id="OUTDOCAPPR" class="tabs-inner" style="height: 300px;"  >
				<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0204.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
			</div>
			<div id="DEPOSITRESULT" class="tabs-inner" style="height: 300px;"  >
				<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0205.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
			</div>
			<div id="MACHINELC" class="tabs-inner" style="height: 300px;"  >
				<jsp:include page="/WEB-INF/jsp/mmyy/mmyy0103p0206.jsp?s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}"/>
			</div>	
           <div class="row">
                <div class="col-7">
                    <!-- 금일진행사항 -->
                    <div class="title-wrap mt10">
                        <h4>금일진행사항</h4>
						<div class="btn-group">
							<div class="right">
								<button type="button" class="btn btn-primary-gra" onclick="goAddCompetiorPrice();">경쟁사정보</button>
								<button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('today')">크게보기</button>
							</div>
						</div>
                    </div>
                    <div style="height: 5px"></div>
<%--                     <c:choose> --%>
<%--                     	<c:when test="${fn:contains(bean.work_text, '</p>') || fn:contains(bean.work_text, '</span>') || fn:contains(bean.work_text, '</div>')}"> --%>
<%--                     		<div contenteditable="true" style="height: 150px; overflow-y: scroll;" class="form-control mt5 editor">${bean.work_text}</div> --%>
<%--                     	</c:when> --%>
<%--                     	<c:otherwise> --%>
<%--                     		<textarea class="form-control mt5" style="height: 150px;" id="work_text" name="work_text" required="required" alt="당일특이사항" >${bean.work_text}</textarea> --%>
						<textarea class="mt5" cols="10" rows="10" style="width:100%; " name="ir1" id="ir1" required="required" alt="당일특이사항" ><c:out value="${bean.work_text}" escapeXml="true"/></textarea>
						<script type="text/javascript">
							var oEditors = [];
							// 추가 글꼴 목록
							//var aAdditionalFontSet = [["MS UI Gothic", "MS UI Gothic"], ["Comic Sans MS", "Comic Sans MS"],["TEST","TEST"]];

							nhn.husky.EZCreator
									.createInIFrame({
										oAppRef : oEditors,
										elPlaceHolder : "ir1",
										sSkinURI : "/SmartEditor/SmartEditor2Skin.html",
										htParams : {
											bUseToolbar : true, // 툴바 사용 여부 (true:사용/ false:사용하지 않음)
											bUseVerticalResizer : true, // 입력창 크기 조절바 사용 여부 (true:사용/ false:사용하지 않음)
											bUseModeChanger : true, // 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
											//aAdditionalFontList : aAdditionalFontSet,		// 추가 글꼴 목록
											fOnBeforeUnload : function() {
												//alert("완료!");
											}
										}, //boolean
										fOnAppLoad : function() {
											//예제 코드
											//oEditors.getById["ir1"].exec("PASTE_HTML", ["로딩이 완료된 후에 본문에 삽입되는 text입니다."]);
										},
										fCreator : "createSEditor2"
									});

							// 											oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
							// 											$("#diaryText").val(document.getElementById("ir1").value);
						</script>
							<%--                     	</c:otherwise> --%>
<%--                     </c:choose> --%>
                    <!-- /금일진행사항 -->
                </div>
                <div class="col-5">
                    <!-- 내일 인사일정 -->
                    <div class="title-wrap mt10">
                        <h4>내일 인사일정</h4>
                    </div>
					<div id="auiGridBottom" style="margin-top: 5px; height: 255px;" ></div>
					<!-- /금일 인사일정 -->
                </div>
	       	</div>
			<div class="row">
				<div>
					<div class="title-wrap mt5">
						<h4>파일업로드</h4>
					</div>
					<table class="table-border mt10">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">첨부파일</th>
								<td colspan="7" style="border-right: white;">
									<div class="table-attfile work_file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
										</div>
									</div>
								</td>
								<td style="border-left: white;">
									<div class="table-attfile" style="display: inline-block; margin: 0 5px;  float: right;">
										<button type="button" class="btn btn-primary-gra mr10"  onclick="javascript:fnFileAllDownload();">파일일괄다운로드</button>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
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
<input type="hidden" id="work_file_seq_1" name="work_file_seq_1" value="${bean.work_file_seq_1 }"/>
<input type="hidden" id="work_file_seq_2" name="work_file_seq_2" value="${bean.work_file_seq_2 }"/>
<input type="hidden" id="work_file_seq_3" name="work_file_seq_3" value="${bean.work_file_seq_3 }"/>
<input type="hidden" id="work_file_seq_4" name="work_file_seq_4" value="${bean.work_file_seq_4 }"/>
<input type="hidden" id="work_file_seq_5" name="work_file_seq_5" value="${bean.work_file_seq_5 }"/>
</form>
</body>
</html>