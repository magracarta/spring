<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무 > 전산 Q&A > null > 전산Q&A상세
-- 작성자 : 박예진
-- 최초 작성일 : 2020-03-16 10:48:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/SmartEditor/js/HuskyEZCreator.js" charset="utf-8"></script>
	<script type="text/javascript">
		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 5;
		// 댓글 카운트
		var replyCnt;
		// 댓글 index 변수
		var idx;
		
		var reFileId;

		// 적용된 태그 목록
		var applyTagCodeList = ${tagCodeList}
		// 전체 태그 목록
		var allTagCodeList = ${allTagList}
		// 사용자가 선택 가능한 태그 목록
		var selTagCodeList = ${selTagList}
		// 최종 저장할 태그 코드
		var resultCodeArr = [];

		// 에디터
		var oAppRefObjs;
		
		$(document).ready(function() {
			if($M.getValue("r_content").trim() == "") {
				// 에디터 내용 초기화
// 				CKEDITOR.instances.r_content.setData(
// 					'<p style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">[답변]<br></p>'
// 				);
			}
			<c:forEach var="list" items="${list}">fnPrintFile('${list.file_seq}', '${list.file_name}');</c:forEach>
			
			// 댓글 추가
// 			$("#total_cnt").html(${total_cnt});
// 			$M.setValue("reply_cnt", ${total_cnt});
// 			replyCnt = ${total_cnt};
// 			idx = parseInt($M.getValue("reply_cnt"));
			
			fnInit();
			
			var reBbsList = ${reBbsList};
			var reBbsFileList = ${reFileMapList};
			fnReplyInit(reBbsList, reBbsFileList);
			
			
		});
		
		function fnReplyInit(reBbsList, reBbsFileList) {
			reFileId = "";
			// 에디터
			oAppRefObjs = {};
			
			$("#reBbsDiv").empty();
			
			// 답글 리스트
			addReBbs(reBbsList);
			
			// 답글 파일 리스트
			fnReFileList(reBbsFileList);

			// 답글추가 버튼
			fnSetReplyBtn();
			
			// 최초 답글목록 에디터 적용
			fnInitEditer();
		}
		
		// 답글 파일 리스트
		function fnReFileList(reFileMapList) {
			$("h4[name='reNum']").each(function() {
				
				var rowNum = $(this).attr("val"); 
				
				var bbsSeq = $(this).attr("bbsSeq");
				var fileList = reFileMapList[bbsSeq];
				for (i in fileList) {
					if(fileList[i].file_seq != 0) {
						reFileId = rowNum;
						fnRePrintFile(fileList[i].file_seq, fileList[i].file_name);
					}
				}
			});
		}
		
		function fnInitEditer() {
			var textAreaIds = [];
			var textAreaTags = $("textarea[name=irrs]");
			for (var i = 0; i < textAreaTags.length; i++) {
				textAreaIds.push(textAreaTags.eq(i).attr("id"));
			}			
			
			for (var i = 0; i < textAreaIds.length; i++) {
				fnSetEditer(textAreaIds[i]);
			}
		}
		
		// 에디터 적용
		function fnSetEditer(textAreaId) {
			
			oAppRefObjs[textAreaId] = [];
			
			nhn.husky.EZCreator.createInIFrame({
				oAppRef: oAppRefObjs[textAreaId],
				elPlaceHolder: textAreaId,
				sSkinURI: "/SmartEditor/SmartEditor2Skin.html",	
				htParams : {
					bUseToolbar : true,				// 툴바 사용 여부 (true:사용/ false:사용하지 않음)
					bUseVerticalResizer : true,		// 입력창 크기 조절바 사용 여부 (true:사용/ false:사용하지 않음)
					bUseModeChanger : true,			// 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
					fOnBeforeUnload : function(){}
				}, //boolean
				fOnAppLoad : function(){},
				fCreator: "createSEditor2"
			});
		}
		
		
		function fnInit() {
			fnApplyTag();

			if($M.getValue("reg_mem_no") != $M.getValue("login_mem_no") && '${page.fnc.F00491_001}' != 'Y') {
				$(".check-dis").prop("disabled", true);
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			}
			if ($M.getValue("reg_mem_no") != $M.getValue("login_mem_no") && '${page.fnc.F00491_007}' != 'Y') {
				$(".check-dis").prop("disabled", true);
				$("#_goSave").addClass("dpn");
			} else {
				$("#_goSave").removeClass("dpn");
			}

			// 개발담당자1 콤보그리드 셋팅
			var bbsChargeStr = $M.getValue("main_y_bbs_charge_cd_str_temp");
			var bbsChargeArr = bbsChargeStr.split("^");
			$('#bbs_charge_cd').combogrid("setValues", bbsChargeArr);

			// 개발담당자2 콤보그리드 셋팅
			var bbsChargeStr2 = $M.getValue("main_n_bbs_charge_cd_str_temp");
			var bbsChargeArr2 = bbsChargeStr2.split("^");
			$('#bbs_charge_cd2').combogrid("setValues", bbsChargeArr2);


			var tagCdArr = "${result.tag_cd}";
			if(tagCdArr != '') {
				// 내가 선택가능한 태그중 적용되어있는거 체크작업 (콤보그리드 최초 로딩시에 체크를 지정 해주어야 함.. 그후엔 자동)
				var arrTagCdSelList = [];
				var applyTagList = tagCdArr.split("^");
				for (var j = 0; j < selTagCodeList.length; j++) {
					if (applyTagList.includes(selTagCodeList[j].code_value)) {
						arrTagCdSelList.push(selTagCodeList[j].code_value);
					}
				}

				$('#arr_tag_cd_sel').combogrid("setValues", arrTagCdSelList);
				$('#view_arr_tag_cd').combogrid("setValues", tagCdArr.split("^"));
			}

			$('input[type=radio][name=cust_comp_yn]').change(function(){
				if($M.getValue("cust_comp_yn") == 'Y'){
					$M.setValue("cust_comp_dt",'${inputParam.s_current_dt}');
				}else{
					$M.setValue("cust_comp_dt","");
				}
			});
			
			//  개발의견은 it_manager만 수정되도록.
			if('${page.fnc.F00491_001}' != 'Y') {
				
				// 답변구분
				$("#bbs_proc_cd").prop("disabled", true);
				
				// 조치예정일
				document.getElementById('reser_dev_dt_div').innerHTML = "";
				
				var reserDevDt = "${result.reser_dev_dt}"
				if (reserDevDt != "") {
					reserDevDt = $M.dateFormat(reserDevDt, 'yyyy-MM-dd');
					$("#reser_dev_dt_div").append(reserDevDt);
				}

				// 개발완료일
				document.getElementById('comp_dt_div').innerHTML = "";
				
				var compDt = "${result.comp_dt}";
				if (compDt != "") {
					compDt = $M.dateFormat(compDt, 'yyyy-MM-dd');
					$("#comp_dt_div").append(compDt);
				}

				// 담당자
				$('#bbs_charge_cd').combogrid('disable');

			}
		}

		// 적용태그 세팅
		function fnApplyTag(tagCdList) {
			var tagCdListArr = [];
			if (tagCdList == '' || tagCdList == undefined) {
			} else {
				tagCdListArr = tagCdList.replaceAll(' ', '').split(',');
			}

			// 사용자가 선택 할 수 있는 코드 목록
			var selTagCodeArr = [];
			for (var i = 0; i < selTagCodeList.length; i++) {
				selTagCodeArr.push(selTagCodeList[i].code_value);
			}

			// 전체에서 선택 가능한 코드를 제외시키면 나머지는 변할수없는 코드들임.
			var notChangeCodeArr = [];
			var notChangeCodeNameArr = [];
			for (var i = 0; i < allTagCodeList.length; i++) {
				var code = allTagCodeList[i].code_value;
				var codeName = allTagCodeList[i].code_name;

				if (selTagCodeArr.includes(code) == false) {
					notChangeCodeArr.push(code);
					notChangeCodeNameArr.push(codeName);
				}
			}

			// 선택하지 못하는 태그중 추가해주어야 할 태그 (이미 선택되어있는)
			var addCodeArr = [];
			var addCodeNameArr = [];
			for (var i = 0; i < applyTagCodeList.length; i++) {
				var code = applyTagCodeList[i].code_value;
				var codeName = applyTagCodeList[i].code_name;

				if (notChangeCodeArr.includes(code)) {
					addCodeArr.push(code);
					addCodeNameArr.push(codeName);
				}
			}

			// 최종 저장할 태그 code
			resultCodeArr = [];
			// 최종 적용 태그에 보여주어야 할 태그 name
			var resultCodeNameArr = [];

			// 최종에 합침
			for (var i = 0; i < addCodeArr.length; i++) {
				resultCodeArr.push(addCodeArr[i]);
				resultCodeNameArr.push(addCodeArr[i]);
			}

			for (var i = 0; i < tagCdListArr.length; i++) {
				resultCodeArr.push(tagCdListArr[i]);
				resultCodeNameArr.push(tagCdListArr[i]);
			}

			// 태그명으로 변환
			for (var i = 0; i < allTagCodeList.length; i++) {
				var code = allTagCodeList[i].code_value;
				for (var j = 0; j < resultCodeNameArr.length; j++) {
					if (code == resultCodeNameArr[j]) {
						resultCodeNameArr[j] = allTagCodeList[i].code_name;
					}
				}
			}

			// 태그명 세팅
			var tagName = resultCodeNameArr.join(', ');
			$M.setValue("arr_tag_cd", tagName);
		}

		// 게시글 수정
		function goModify() {

			// 개발담당자 1,2 중복 체크
			var bbsChargeCd = $M.getValue("bbs_charge_cd").replace(",", "");
			var chargeArr1 = bbsChargeCd.split("#");
			var bbsChargeCd2 = $M.getValue("bbs_charge_cd2").replace(",", "");
			var chargeArr2 = bbsChargeCd2.split("#");
			var includeArr = chargeArr1.filter(x => chargeArr2.includes(x));

			var realIncludeArr = [];

			for (var i = 0; i < includeArr.length; i++) {
				if (includeArr[i] != '') {
					realIncludeArr.push(includeArr[i]);
				}
			}


			if (realIncludeArr.length > 0) {
				alert("개발담당자1,2에 중복으로 지정된 담당자가 있습니다.");
				return false;
			}

			// 문의글 밸리데이션 체크
			var frm = document.main_form;
			//내용 input으로 등록
// 			$M.setValue("content", CKEDITOR.instances.content.getData());
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
			$M.setValue("content", $M.getValue("ir1"));
			if ($M.validation(frm) == false) {
				return;
			}
			;

			// 파일 중복등록으로 인해 체크.
			if (confirm("수정하시겠습니까?") == false) {
				return false;
			}

			var idx = 1;
			$("input[name='file_seq']").each(function () {
				var str = 'bbs_file_seq_' + idx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			for (; idx <= fileCount; idx++) {
				$M.setValue('bbs_file_seq_' + idx, 0);
			}

// 			$M.setValue("bbs_charge_cd_str", $M.getValue("bbs_charge_cd"));
			$M.setValue("b_bbs_charge_cd_str", $M.getValue("bbs_charge_cd"));
			$M.setValue("b_bbs_charge_cd2_str", $M.getValue("bbs_charge_cd2"));
			$M.setValue("tag_cd_str", $M.getArrStr(resultCodeArr, {isEmpty : true}));

			$M.goNextPageAjax(this_page + '/modify', $M.toValueForm(frm), {method: 'POST'},
					function (result) {
						if (result.success) {
							fnClose();
							if (opener != null && opener.goSearch) {
								opener.goSearch();
							}
						}
					}
			);
		}
		
		// 게시글 삭제
		function goRemove(bbsSeq, rowNum) {
			if(!bbsSeq) {
				bbsSeq = '${inputParam.bbs_seq}'
			}
			$M.goNextPageAjaxRemove(this_page + "/remove/"+bbsSeq, '', { method : "POST"},
				function(result) {
					if(result.success) {
						if (!rowNum) {
							fnClose();
						} else {
							$("#reHtml_"+rowNum).remove();
							fnSetReplyBtn();
						}
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
					};
				}
			);
		}
		
		/* 
		// 답변 저장
		function goSave() {
			
			var frm = document.main_form;

			$M.setValue("bbs_charge_cd_str_temp", $M.getValue("bbs_charge_cd"));
			
			//내용 input으로 등록
// 			$M.setValue("r_content", CKEDITOR.instances.r_content.getData());
// 			for (var i = 0; i < Object.keys(oAppRefObj).length; i++) {
// 				Object.valuse(oAppRefObj)[i].getById["irr_1"].exec("UPDATE_CONTENTS_FIELD", []);
// 			}

// 			for (key in oAppRefObj) {
// 				oAppRefObj[key]
// 			}
			
// 			var tempA = Object.keys(oAppRefObjs)[0];
			var tempA = oAppRefObjs.irr_1;
			tempA.getById["irr_1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
 			$M.setValue("r_content", $M.getValue("irr_1"));
			// 게시글은 required로, 답변은 따로 필수값 체크
			if($M.validation(document.main_form, {field:["r_bbs_proc_cd", "r_content"]}) == false) {
				return;
			};
 			$M.setValue("bbs_charge_cd_str", $M.getValue("bbs_charge_cd"));
 			
			// cmd가 C일 경우 등록
			$M.goNextPageAjaxSave(this_page + '/reply/save', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
						fnClose();
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
					}
				}
			);
		}
		 */
		
		// 첨부파일 출력
		function fnPrintFile(fileSeq, fileName) {
			var str = ''; 
			str += '<div class="table-attfile-item bbs_file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.bbs_file_div').append(str);
			fileIndex++;
		}
		
		 
		// 답글 첨부파일 출력
		function fnRePrintFile(fileSeq, fileName) {
			var str = ''; 
			str += '<div class="table-attfile-item re_bbs_file_' + fileSeq + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="re_' + reFileId + '_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnReRemoveFile(' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.bbs_file_div_'+reFileId).append(str);
// 			fileIndex++;
			
			reFileId = "";
		}
		
		// 첨부파일 버튼 클릭
		function fnAddFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=BBS&file_type=both&max_size=2048');
		}
		
		// 답변 첨부파일 버튼 클릭
		function fnAddFileRe(rowNum){
			reFileId = rowNum;
			
			if($("input[name='re_" + reFileId + "_file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setReFileInfo', 'upload_type=BBS&file_type=both&max_size=2048');
		}
		
		function setReFileInfo(result) {
			fnRePrintFile(result.file_seq, result.file_name);
		}
		
		function setFileInfo(result) {
			fnPrintFile(result.file_seq, result.file_name);
		}
		
		// 답글 첨부파일 삭제
		function fnReRemoveFile(fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".re_bbs_file_" + fileSeq).remove();
			} else {
				return false;
			}
			
		}
		
		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".bbs_file_" + fileIndex).remove();
			} else {
				return false;
			}
			
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}

		

		// 에디터 관련
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
		
		// 댓글 저장
		function goReplyNew() {
			var frm = document.main_form;
			// 게시글은 required로, 답변은 따로 필수값 체크
			if($M.validation(document.main_form, {field:["r_insert_content"]}) == false) {
				return;
			};
			
			var param = {
					"bbs_seq" : $M.getValue("bbs_seq"),
					"content" : $M.getValue("r_insert_content"),
			}
			$M.goNextPageAjaxSave(this_page + '/reply/replySave', $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						var cnt =  idx;
						var reg_date = $M.dateFormat(new Date(result.reg_date), "yyyy-MM-dd HH:mm:ss");
						var str = ''; 
						str += '<div class="comment-item" id="idx_' + cnt + '">';
						str += '<input type="hidden" value="' + result.bbs_comment_seq + '" id="bbs_comment_seq_' + cnt + '" name="bbs_comment_seq_' + cnt + '">';
						str += '<div class="comment-info">';
						str += '<span>' + result.org_name + '</span><span>' + result.reg_mem_name + '</span><span>'+ reg_date + '</span>';
						str += '</div>';
						str += '<div>';
						str += '<div class="comment-text" id="reply-content-modify">';
						str += '<textarea type="text" class="form-control mr5" id="r_content_' + cnt + '" name="r_content_' + cnt + '" style="height: 50px;">' + result.content + '</textarea>';
						str += '</div>';
						str += '<div>';
						str += '<button type="button" class="btn btn-default" id="btn_modify" value="' + cnt + '" onclick="javascript:goReplyModify(value);">수정</button>';
						str += '<button type="button" class="btn btn-default" id="btn_remove" value="' + cnt + '" onclick="javascript:goReplyRemove(value);">삭제</button>';
						str += '<div>';
						$('.comment-body').prepend(str);
// 						var totalCnt = replyCnt;
// 						$("#total_cnt").html(totalCnt + 1);
						$M.setValue("r_insert_content", "");
// 						idx++;
// 						replyCnt++;
						alert("저장이 완료되었습니다.");
					}
				}
			);
		}
		
		// 댓글 수정
		function goReplyModify(cnt) {
			var frm = document.main_form;
			if($M.validation(document.main_form, {field:["r_content_" + cnt]}) == false) {
				return;
			};
			var param = {
					"bbs_seq" : $M.getValue("bbs_seq"),
					"content" : $M.getValue("r_content_" + cnt),
					"seq_no" : $M.getValue("bbs_comment_seq_" + cnt),
			}
			console.log(param);
			$M.goNextPageAjaxModify(this_page + '/reply/replySave', $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
		}
		
		// 댓글 삭제
		function goReplyRemove(cnt) {
			var param = {
					"seq_no" : $M.getValue("bbs_comment_seq_" + cnt),
					"bbs_seq" : $M.getValue("bbs_seq"),
			}
			$M.goNextPageAjaxRemove(this_page + "/replyRemove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						$("#idx_" + cnt).hide();
					};
				}
			);
		}
		
		// 답변구분 검수완료 선택시 검수완료체크
		function fnSetBbsProc() {
			if($M.getValue("bbs_proc_cd") == "E") {
				$M.setValue("cust_comp_yn", "Y");
			} else {
				$M.setValue("cust_comp_yn", "");
				$("#comp_mem_name").text("");
				$M.setValue("comp_mem_no", "");
				$("#cust_comp_dt_name").text("");
				$M.setValue("cust_comp_dt", "");
			}
		}
		
		// 고객 검수완료 클릭시
		function fnSetCustComp() {
			if("Y" == $M.getValue("cust_comp_yn")) {
				$M.setValue("bbs_proc_cd", "E");
				
				$("#comp_mem_name").text("${SecureUser.kor_name}");
				$M.setValue("comp_mem_no", "${SecureUser.mem_no}");
				
				var today = new Date();
				var year = today.getFullYear();
				var month = ('0' + (today.getMonth() + 1)).slice(-2);
				var day = ('0' + today.getDate()).slice(-2);
// 				var hours = ('0' + today.getHours()).slice(-2); 
// 				var minutes = ('0' + today.getMinutes()).slice(-2);
// 				var seconds = ('0' + today.getSeconds()).slice(-2);
// 				var nowDate = year+"-"+month+"-"+day+" "+hours+":"+minutes+":"+seconds;
				var nowDayFormat = year+"-"+month+"-"+day;
				var nowDay = year+month+day+"";
				$("#cust_comp_dt_name").text(nowDayFormat);
				$M.setValue("cust_comp_dt", nowDay);
			} else {
				// 원래값 있으면 돌아가도록.
				var bbsProcCd = "${result.bbs_proc_cd}";
				bbsProcCd = bbsProcCd == "E" ? "P" : bbsProcCd; // 원래 "검수완료" 였으면 "진행"으로
				$M.setValue("bbs_proc_cd", bbsProcCd);
				
				$("#comp_mem_name").text("");
				$M.setValue("comp_mem_no", "");
				
				$("#cust_comp_dt_name").text("");
				$M.setValue("cust_comp_dt", "");
			}
		}
		
		
		
		// 답글 추가
		function addReBbs(param) {
			
			var textareaArr = [];
			
			
			var paramObj = {};
			var isNew = false;
			
			// 답글 새로 작성이면 초기값 세팅
			if (!Array.isArray(param)) {
				isNew = true;
				param = [];
				
				// Re 순번, textareaId 구하기
				var reNums = $("h4[name=reNum]");
				var textareas = $("textarea[name=irrs]");
				
				var newNum = 1;
				if(reNums.length > 0) {
					var lastNum = reNums.eq(reNums.length-1).attr("val");
					newNum = $M.toNum(lastNum) + 1;
				}
				
				paramObj["re_num"] = newNum;
				paramObj["textarea_id"] = newNum;
				
				paramObj["bbs_seq"] = "0";
				paramObj["title"] = "";
				paramObj["content"] = "";
				paramObj["reg_mem_no"] = "${SecureUser.mem_no}";
				paramObj["reg_mem_name"] = "${SecureUser.kor_name}";
				paramObj["reg_date"] = "";
				

				param.push(paramObj);
			}
			
			for (var i = 0; i < param.length; i++) {
				var reBbsHtml = "";
				
				var thClass = fnGetThClass();
				
				var regMemName = param[i].reg_mem_name || "";
				
				reBbsHtml += '<div name="reHtml" id="reHtml_' + param[i].re_num + '">';
				reBbsHtml += '<div class="row">';
				reBbsHtml += '	<div class="btn-group">';
				reBbsHtml += '		<div class="left">';
				reBbsHtml += '			<h4 name="reNum" val="' + param[i].re_num + '" bbsSeq = "' + param[i].bbs_seq + '">Re ' + param[i].re_num + ' [' + regMemName + '] ' + param[i].reg_date + '</h4>';
				reBbsHtml += '		</div>';
				reBbsHtml += '	</div>';
				reBbsHtml += '	<table class="table-border">';
				reBbsHtml += '		<colgroup>';
				reBbsHtml += '			<col width="100px">';
				reBbsHtml += '			<col width="">';
				reBbsHtml += '			<col width="">';
				reBbsHtml += '			<col width="">';
				reBbsHtml += '			<col width="">';
				reBbsHtml += '			<col width="">';
				reBbsHtml += '		</colgroup>';
				reBbsHtml += '		<tbody>';
// 				reBbsHtml += '			<tr>';
// 				reBbsHtml += '				<th class="text-right essential-item">제목</th>';
// 				reBbsHtml += '				<td colspan="5">';
// 				reBbsHtml += '					<div class="input-group">';
// 				reBbsHtml += '						<input type="hidden" id="bbs_seq_' + param[i].re_num + '" value="' + param[i].bbs_seq + '">';
// 				reBbsHtml += '						<input type="text" class="form-control essential-bg check-dis" id="title_' + param[i].re_num + '" name="title" alt="제목" maxlength="2000" required="required" value="' + param[i].title + '">';
// 				reBbsHtml += '					</div>';
// 				reBbsHtml += '				</td>';
// 				reBbsHtml += '			</tr>';
				reBbsHtml += '			<tr>';
				reBbsHtml += '				<th class="text-right essential-item" ' + thClass + '>답변내용</th>';
				reBbsHtml += '				<td colspan="5" class="v-align-top" style="height: 200px;">';
				reBbsHtml += '					<textarea name="irrs" id="irr_' + param[i].textarea_id + '" rows="10" cols="100" style="width:100%; height:400px; " >' + param[i].content + '</textarea>';
				reBbsHtml += '				</td>';
				reBbsHtml += '			</tr>';
				reBbsHtml += '			<tr>';
				reBbsHtml += '				<th class="text-right" ' + thClass + '>첨부파일</th>';
				reBbsHtml += '				<td colspan="3">';
				reBbsHtml += '					<div class="table-attfile bbs_file_div_' + param[i].re_num +' style="width:100%;">';
				reBbsHtml += '						<div class="table-attfile" style="float:left">';
				reBbsHtml += '						<button type="button" class="btn btn-primary-gra mr10 check-dis" name="file_add_btn" id="file_add_btn" onclick="javascript:fnAddFileRe('+param[i].re_num+');">파일찾기</button>';
				reBbsHtml += '						&nbsp;&nbsp;';
				reBbsHtml += '						</div>';
				reBbsHtml += '					</div>';
				reBbsHtml += '				</td>';
				
				reBbsHtml += '				<td colspan="2">';
				reBbsHtml += '<div class="btn-group">';
				reBbsHtml += '		<div class="left">';
				reBbsHtml += '			<div class="form-check form-check-inline paper_div_' + param[i].re_num + '">';
				
				reBbsHtml += '			</div>';
				reBbsHtml += '		</div>';
				reBbsHtml += '	<div class="right">';
				reBbsHtml += '		<div class="urBtn_' + param[i].re_num + '" style="display:inline;"></div>';
				
				if (isNew) {
					reBbsHtml += '<div class="btn-group mt10 reNewSaveDiv_' + param[i].re_num + '" style="display:inline;">';
					reBbsHtml += '	<div class="right" style="display:inline;">';
					reBbsHtml += '		<button type="button" id="" class="btn btn-info" onclick="javascript:goReBbsSave('+param[i].re_num+', \'C\');">답글저장</button>';
					reBbsHtml += '	</div>';
					reBbsHtml += '</div>';
				}
				reBbsHtml += '	</div>';
				reBbsHtml += '</div>';
				
				reBbsHtml += '				</td>';
				
				reBbsHtml += '			</tr>';
				reBbsHtml += '		</tbody>';
				reBbsHtml += '	</table>';
				reBbsHtml += '	<div class="btn-group mt5">';
				reBbsHtml += '		<div class="right">';
				reBbsHtml += '			<div class="addReplyBtnDiv" style="display:inline;"></div>';
				reBbsHtml += '		</div>';
				reBbsHtml += '	</div>';
				reBbsHtml += '</div>';
				
				
				reBbsHtml += '</div>';
				
				textareaArr.push("irr_"+param[i].textarea_id);
				
				$('#reBbsDiv').append(reBbsHtml);
			}
			
			
			
			// 답글추가 버튼제거
			fnSetRemoveReplyBtn();
			
			for (i in param) {
				fnAddUpdateRemoveBtn(param[i].re_num, param[i].bbs_seq, param[i].reg_mem_no);
				fnAddPaperBtn(param[i].re_num, param[i].reg_mem_no);
			}
			
			// 에디터 설정
			if (isNew) {
				for (i in textareaArr) {
					fnSetEditer(textareaArr[i]);
				}
			}
		}
		
		function fnGetThClass() {
			var thClass = "";
			var rowTags = $("div[name=reHtml]");
			var rowTagsLength = rowTags.length;
			
			if (rowTagsLength%2 == 0) {
// 				thClass = "th-orange";
				thClass = 'style="background-color: #eee; color: black;"';
			} else {
				thClass = 'style="background-color: silver; color: black;"';
			}
			return thClass;
		}
		
		// 답글추가 버튼
		function fnSetReplyBtn() {
			
			fnSetRemoveReplyBtn();
			
			
			// it_manger or 검수완료 아닐경우만 버튼추가.
			if("E" != "${result.bbs_proc_cd}" || '${page.fnc.F00491_001}' == 'Y') {
				var btnHtml = "";
				btnHtml += '		<button type="button" class="btn btn-info replyBtn" id="" value="" onclick="javascript:addReBbs();">답글추가</button>';
				
				var btnDivs = $(".addReplyBtnDiv");
				$(btnDivs[btnDivs.length-1]).append(btnHtml);
			}
		}
		
		// 답글추가 버튼 삭제
		function fnSetRemoveReplyBtn() {
			$('.replyBtn').remove();
		}
		
		// 수정,삭제 버튼 추가
		function fnAddUpdateRemoveBtn(rowNum, bbsSeq, regId) {
			// it_manger or 검수완료 아닐경우만 버튼추가.
			if("${SecureUser.mem_no}" == regId && bbsSeq != "0") {
				var btnHtml = "";
				btnHtml += '		<button type="button" id="" class="btn btn-info" onclick="javascript:goReBbsSave('+rowNum+', \'U\', ' + bbsSeq + ');">답글수정</button>';
				btnHtml += '		<button type="button" id="" class="btn btn-info" onclick="javascript:goRemove('+bbsSeq+', ' + rowNum +');">답글삭제</button>';
				
				$(".urBtn_"+rowNum).append(btnHtml);
			}
		}
		
		// 쪽지 전송 버튼
		function fnAddPaperBtn(rowNum, regId) {
			if("${SecureUser.mem_no}" == regId) {
				var paperHtml = '';
				paperHtml += '<input class="form-check-input" type="checkbox" id="paper_' + rowNum + '" name="paper_' + rowNum + '" value="Y" checked="checked">';
				paperHtml += '<label class="form-check-label mr5" for="paper_' + rowNum + '" >쪽지전송여부</label>';
			
				$(".paper_div_"+rowNum).append(paperHtml);
			}
		}
					
		/*
			rowNum : 답글순번
			saveType : 'U' 업데이트, 'C' 새로저장
		*/					
		function goReBbsSave(rowNum, saveType, bbsSeq) {
			var frm = document.main_form;
			var textAreaFullId = "irr_" + rowNum;
			
			(oAppRefObjs[textAreaFullId]).getById[textAreaFullId].exec("UPDATE_CONTENTS_FIELD", []);
			$M.setValue("r_content", $("#"+textAreaFullId).val());
// 			$M.setValue("r_title", $("#title_"+rowNum).val());
			$M.setValue("r_bbs_seq", bbsSeq);
			
// 			if($M.getValue("r_title") == "") {
// 				alert("제목은 필수 입력입니다.");
// 				return false;
// 			}
			if($M.getValue("r_content") == "") {
				alert("내용은 필수 입력입니다.");
				return false;
			}
			
			var idx = 1;
			$("input[name='re_"+rowNum+"_file_seq']").each(function() {
				var str = 'r_bbs_file_seq_' + idx;
				// 첨부파일 중복 등록으로 인하여 체크 - 김경빈
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue("r_bbs_file_seq_"+idx, $(this).val());
				}
				idx++;
			});
			
			$M.setValue("r_paper_yn", $M.getValue("paper_"+rowNum));
			
			$M.goNextPageAjaxSave(this_page + '/reply/save', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
// 						fnClose();
// 						location.reload();
						if(saveType == 'C') {
							$(".reNewSaveDiv_"+rowNum).remove();
							fnSetReplyBtn();
							fnAddUpdateRemoveBtn(rowNum, result.new_bbs_seq, "${SecureUser.mem_no}");
						}
// 						goReplySearch();
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
					}
				}
			);
		}
		
		function goReplySearch() {
			var upBbsSeq = "${inputParam.bbs_seq}";
			$M.goNextPageAjax(this_page + "/reply/" + upBbsSeq, "", {method : 'get'},
				function(result) {
					if(result.success) {
						fnReplyInit(result.reBbsList, result.reFileMapList)
					};
				}
			);
		}
		
		// 작성자 변경팝업 응답
		function setBbsRegMemNo(result) {
			$M.setValue("reg_mem_name", result.mem_name);
			$M.setValue("reg_mem_no", result.mem_no);
		}


	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="login_mem_no" name="login_mem_no" value="${SecureUser.mem_no}"> <!-- 로그인한 유저 -->
	<input type="hidden" id="login_org_code" name="login_org_code" value="${SecureUser.org_code}"> <!-- 로그인한 유저 -->
	<input type="hidden" id="main_y_bbs_charge_cd_str_temp" name="main_y_bbs_charge_cd_str_temp"
		   value="${result.main_y_bbs_charge_cd}">
	<input type="hidden" id="main_n_bbs_charge_cd_str_temp" name="main_n_bbs_charge_cd_str_temp"
		   value="${result.main_n_bbs_charge_cd}">
	<input type="hidden" id="bbs_charge_cd_str" name="bbs_charge_cd_str">
	<input type="hidden" id="mng_yn" name="mng_yn" value="${mngYn}"> <!-- 답변가능여부 -->
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
<!-- 폼테이블 -->	
			<div>
				<div class="btn-group">
					<div class="left">
						<h4>전산 Q&A 문의하기</h4>
					</div>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">
								부서
							</th>
							<td>
								<input type="text" class="form-control width140px check-dis" name="org_name" id="org_name" value="${result.org_name}" readonly="readonly" alt="부서명">
								<input type="hidden" name="org_code" id="org_code" value="${inputParam.org_code}" >
								<input type="hidden" name="read_cnt" id="read_cnt" value="${result.read_cnt}" >
								<input type="hidden" id="bbs_seq" name="bbs_seq" value="${inputParam.bbs_seq}">
							</td>
							<th class="text-right">고객담당자</th>
							<td>
								<input type="text" class="form-control width110px check-dis" name="reg_mem_name" id="reg_mem_name" value="${result.reg_mem_name}" readonly="readonly" style="display: inline;">
								<input type="hidden" name="reg_mem_no" id="reg_mem_no" value="${result.reg_mem_no}" >
								<c:if test="${page.fnc.F00491_001 eq 'Y'}">
									<button type="button" class="btn btn-info" onclick="javascript:openMemberOrgPanel('setBbsRegMemNo', 'N');" style="display: inline;">고객담당자변경</button>
								</c:if>
							</td>
							<th class="text-right">작성일시</th>
							<td>
								<fmt:formatDate value="${result.reg_date}" pattern="yyyy-MM-dd HH:mm:ss" var="reg_dt"/>
								<input type="text" class="form-control width140px check-dis" name="dis_reg_dt" id="dis_reg_dt" value="${reg_dt}" readonly="readonly" style="display: inline;">
								${result.real_reg_mem_name}
							</td>							
						</tr>
						<tr>
							<th class="text-right">상태</th>
							<td>
								<input type="text" class="form-control width120px check-dis" value="${result.bbs_proc_name}" readonly>
							</td>	
							<th class="text-right essential-item">구분</th>
							<td>
								<select class="form-control essential-bg width140px check-dis" id="bbs_cate_cd" name="bbs_cate_cd" alt="구분" required="required">
									<c:forEach var="item" items="${codeMap['BBS_CATE']}">
									<option value="${item.code_value}" ${item.code_value == result.bbs_cate_cd ? 'selected' : '' }>${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right essential-item">완료요청일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 essential-bg width120px calDate check-dis" id="reser_comp_dt" name="reser_comp_dt" value="${result.reser_comp_dt}" dateformat="yyyy-MM-dd" alt="완료요청일" >
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">제목</th>
							<td colspan="3">
								<input type="text" class="form-control essential-bg check-dis" id="title" name="title" alt="제목" maxlength="2000" required="required" value="${result.title}">
							</td>
							<th class="text-right">태그</th>
							<td>
								<input class="form-control" style="width: 99%;" type="text" id="view_arr_tag_cd" name="view_arr_tag_cd" easyui="combogrid" required
									   easyuiname="viewTagList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y" disabled="disabled"/>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">내용</th>
							<td colspan="5" class="v-align-top" style="height: 200px;">
										<textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:550px; display:none;" >${result.content}</textarea>
											<script type="text/javascript">
													var oEditors = [];
													// 추가 글꼴 목록
													//var aAdditionalFontSet = [["MS UI Gothic", "MS UI Gothic"], ["Comic Sans MS", "Comic Sans MS"],["TEST","TEST"]];
													
													nhn.husky.EZCreator.createInIFrame({
														oAppRef: oEditors,
														elPlaceHolder: "ir1",
														sSkinURI: "/SmartEditor/SmartEditor2Skin.html",	
														htParams : {
															bUseToolbar : true,				// 툴바 사용 여부 (true:사용/ false:사용하지 않음)
															bUseVerticalResizer : true,		// 입력창 크기 조절바 사용 여부 (true:사용/ false:사용하지 않음)
															bUseModeChanger : true,			// 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
															//aAdditionalFontList : aAdditionalFontSet,		// 추가 글꼴 목록
															fOnBeforeUnload : function(){
																//alert("완료!");
															}
														}, //boolean
														fOnAppLoad : function(){
															//예제 코드
															//oEditors.getById["ir1"].exec("PASTE_HTML", ["로딩이 완료된 후에 본문에 삽입되는 text입니다."]);
														},
														fCreator: "createSEditor2"
													});
													
		// 											oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
		// 											$("#diaryText").val(document.getElementById("ir1").value);
											</script>
							</td>
						</tr>
						<tr>
							<th class="text-right">첨부파일</th>
							<td colspan="5">
								<div class="table-attfile bbs_file_div" style="width:100%;">
									<div class="table-attfile" style="float:left">
									<button type="button" class="btn btn-primary-gra mr10 check-dis" name="file_add_btn" id="file_add_btn" onclick="javascript:fnAddFile();">파일찾기</button>
									&nbsp;&nbsp;
									</div>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
				<div class="btn-group mt10">
					<div class="right">
						<div class="addReplyBtnDiv"></div>
					</div>
				</div>
			</div>
<!-- /폼테이블 -->
<!-- 댓글영역 -->
			<div class="comment-header mt15">				
				<div class="title-comment">
					<i class="material-iconschat text-default"></i>Comment
				</div>
				<div class="comment-input-item">
					<textarea type="text" class="form-control mr5" id="r_insert_content" name="r_insert_content" alt="Comment" style="height: 50px;"></textarea>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
				</div>
			</div>
			<div class="comment-body">
				<c:forEach var="row" items="${replyList}" varStatus="status">
                   <div class="comment-item" id="idx_${status.index}">
                 		<input type="hidden" value="${row.bbs_comment_seq}" id="bbs_comment_seq_${status.index}" name="bbs_comment_seq_${status.index}">
							<div class="comment-info">
								<span>${row.org_name}</span><span>${row.r_reg_mem_name}</span><span><fmt:formatDate value="${row.r_reg_date}" pattern="yyyy-MM-dd HH:mm:ss" var="reg_dt"/>${reg_dt}</span>
							</div>
							<div>
							<c:choose>
								<c:when test="${SecureUser.mem_no eq row.r_reg_mem_no}">
								<div class="comment-text" id="reply-content-modify">
									<textarea type="text" class="form-control mr5" id="r_content_${status.index}" name="r_content_${status.index}" style="height: 50px;">${row.r_content}</textarea>
								</div>
								<div>
									<button type="button" class="btn btn-default" id="btn_modify" value="${status.index}" onclick="javascript:goReplyModify(value);">수정</button>
									<button type="button" class="btn btn-default" id="btn_remove" value="${status.index}" onclick="javascript:goReplyRemove(value);">삭제</button>
								</div>
								</c:when>
								<c:otherwise>
								<div class="comment-text" id="reply-content">
									${row.r_content}
								</div>
								</c:otherwise>
							</c:choose>
						</div>
					</div>
				</c:forEach>
			</div>			
<!-- /댓글영역 -->
<!-- 답변, 코멘트 -->
			<div id="reBbsDiv">
<!-- 답변테이블 -->
<!-- /댓글영역 -->
			</div>
<!-- /답변, /코멘트 -->
<!-- 검수 테이블 -->
			<div class="row mt10">
				<div class="btn-group">
					<div class="left">
						<h4>개발자의견</h4>
					</div>
				</div>
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">답변구분</th>
							<td colspan="3">
								<select class="form-control essential-bg width100px" id="bbs_proc_cd" name="bbs_proc_cd" alt="답변구분" onchange="javascript:fnSetBbsProc()">
									<c:forEach var="item" items="${codeMap['BBS_PROC']}">
<%-- 									<c:if test="${item.code_name ne '요청'}"> --%>
									<option value="${item.code_value}" ${item.code_value == result.bbs_proc_cd ? 'selected' : '' }>${item.code_name}</option>
<%-- 									</c:if> --%>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">조치예정일</th>
							<td colspan="2">
								<div class="input-group" id="reser_dev_dt_div">
									<input type="text" class="form-control border-right-0 width120px calDate" id="reser_dev_dt" name="reser_dev_dt" dateformat="yyyy-MM-dd" alt="조치예정일" value="${result.reser_dev_dt}">
								</div>
							</td>
							<th class="text-right">개발완료일</th>
							<td colspan="2">
								<div class="input-group" id="comp_dt_div">
									<input type="text" class="form-control border-right-0 width120px calDate" id="comp_dt" name="comp_dt" dateformat="yyyy-MM-dd" alt="개발완료일" value="${result.comp_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">개발담당자1</th>
							<td colspan="3">
								<input class="form-control" style="width:250px;" type="text" id="bbs_charge_cd"
									   name="bbs_charge_cd" easyui="combogrid"
									   easyuiname="memNoList" panelwidth="150" idfield="code_value"
									   textfield="code_name" multi="Y"/>
							</td>
							<th class="text-right">개발담당자2</th>
							<td colspan="5">
								<input class="form-control" style="width:250px;" type="text" id="bbs_charge_cd2"
									   name="bbs_charge_cd2" easyui="combogrid"
									   easyuiname="memNoList2" panelwidth="150" idfield="code_value"
									   textfield="code_name" multi="Y"/>
							</td>
						</tr>
					</tbody>
				</table>
				<div class="btn-group mt15">
					<div class="left" style="display: inline; ">
						<h4>고객의견</h4>
					</div>
					<div class="right" style="display: inline; float: right;">
						<button type="button" id="" class="btn btn-info" onclick="javascript:goModify();"
								style="margin-bottom: 3px">고객의견 저장
						</button>
					</div>
				</div>
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right " >검수완료여부</th>
							<td colspan="3">
								<div class="right">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="cust_comp_yn" name="cust_comp_yn" value="Y"  onclick="javascript:fnSetCustComp()" ${result.cust_comp_yn == "Y" ? 'checked="checked"' : ''}>
										<label class="form-check-label mr5" for="cust_comp_yn" >검수완료</label>
									</div>
								</div>
							</td>
							<th class="text-right">검수자</th>
							<td colspan="2">
								<span id="comp_mem_name">${result.comp_mem_name}</span>
								<input type="hidden" id="comp_mem_no" name="comp_mem_no" value="${result.comp_mem_no}" >
							</td>
							<th class="text-right">검수날짜</th>
							<fmt:parseDate value="${result.cust_comp_dt}" var="custCompDt" pattern="yyyyMMdd"/>
							<td colspan="2">
								<span id="cust_comp_dt_name" dateformat="yyyy-MM-dd"><fmt:formatDate value="${custCompDt}" pattern="yyyy-MM-dd"/></span>
								<input type="hidden" id="cust_comp_dt" name="cust_comp_dt" value="${result.cust_comp_dt}" >
							</td>
						</tr>
						<tr>
							<th class="text-right">적용 태그</th>
							<td colspan="6">
<%--								<input class="form-control" style="width: 99%;" type="text" id="arr_tag_cd" name="arr_tag_cd" easyui="combogrid" required--%>
<%--									   easyuiname="tagList" panelwidth="0" idfield="code_value" textfield="code_name" multi="Y" readonly />--%>
								<input class="form-control" type="text" id="arr_tag_cd" name="arr_tag_cd" alt="적용 태그" readonly>
							</td>
							<td colspan="1" style="padding: 0 0 0 0">
								<div class="btn-group">
									<div class="left" style="text-align: center;">
										<div class="form-check form-check-inline" style="margin: 0 0 0 0; ">
											<input class="form-check-input" type="checkbox" id="cust_paper_yn" name="cust_paper_yn" value="Y" checked="checked">
											<label class="form-check-label mr5" for="cust_paper_yn" style="margin-right: 0" >쪽지전송여부</label>
										</div>
									</div>
								</div>
							</td>
							<td colspan="2">
								<c:if test="${page.fnc.F00491_001 eq 'Y'}">
									<div class="">
                              			<div class="">
											<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
		                                        <jsp:param name="required_field" value=""/>
		                                        <jsp:param name="s_org_code" value=""/>
		                                        <jsp:param name="s_work_status_cd" value=""/>
		                                        <jsp:param name="readonly_field" value=""/>
		                                        <jsp:param name="execFuncName" value=""/>
		                                    </jsp:include>
	                                   	</div>
	                                </div>
								</c:if>
							</td>
						</tr>
						<tr>
							<th class="text-right">태그 선택</th>
							<td colspan="6">
								<input class="form-control" style="width: 99%;" type="text" id="arr_tag_cd_sel" name="arr_tag_cd_sel" easyui="combogrid" required
									   easyuiname="tagList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y" change="fnApplyTag(this.value);" />
							</td>
							<c:if test="${SecureUser.mem_no eq 'MB00000431'}">
								<th class="text-right">작업공수(M/D)</th>
								<td colspan="2">
									<input type="text" class="form-control width80px" format="decimal" id="work_hour" name="work_hour" value="${result.work_hour}">
								</td>
							</c:if>
						</tr>
					</tbody>
				</table>
				
			</div>
<!-- /검수 테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="mem_no" value="${page.fnc.F00491_001 eq 'Y' ? '' : result.reg_mem_no }"/>
						<jsp:param name="show_yn" value="${result.r_bbs_proc_cd eq 'E' ? 'N' : 'Y'}"/>
					</jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
<input type="hidden" id="bbs_file_seq_1" name="bbs_file_seq_1" value="${result.bbs_file_seq_1 }"/>
<input type="hidden" id="bbs_file_seq_2" name="bbs_file_seq_2" value="${result.bbs_file_seq_2 }"/>
<input type="hidden" id="bbs_file_seq_3" name="bbs_file_seq_3" value="${result.bbs_file_seq_3 }"/>
<input type="hidden" id="bbs_file_seq_4" name="bbs_file_seq_4" value="${result.bbs_file_seq_4 }"/>
<input type="hidden" id="bbs_file_seq_5" name="bbs_file_seq_5" value="${result.bbs_file_seq_5 }"/>
<input type="hidden" id="cmd" name="cmd" value="C">
</form>
</body>
</html>
