<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 파일 드래그앤 드랍 팝업 (그룹 다중)
-- 작성자 : 황빛찬
-- 최초 작성일 : 2022-10-17 15:01:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 파일 정보 담을
		var myDataTranster = new DataTransfer();
		// 파일 개수 체크
		var fileTotalCount = 0;

		var fileSumSize = 0;

		var fileValidCount = 1;

		// 이미지 확장자
		var imgExt = ['jpg', 'jpeg', 'png', 'gif'];
		// 일반파일 확장자
		// 변경시 아래 첨부 가능 파일 종류 에도 수정바람.
		var etcExt = ['txt', 'ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx', 'hwp', 'pdf', 'mp4', 'mov'];

		// 파일 아이콘
		var fileIcon = {
			'txt' : 'icon-file-attach-sm txt',
			'ppt' : 'icon-file-attach-sm ppt',
			'pptx': 'icon-file-attach-sm pptx',
			'doc' : 'icon-file-attach-sm doc',
			'docx': 'icon-file-attach-sm docx',
			'xls' : 'icon-file-attach-sm xls',
			'xlsx': 'icon-file-attach-sm xlsx',
			'hwp' : 'icon-file-attach-sm hwp',
			'pdf' : 'icon-file-attach-sm pdf',
			'jpg' : 'icon-file-attach-sm jpg',
			'jpeg' : 'icon-file-attach-sm jpeg',
			'png' : 'icon-file-attach-sm png',
			'gif' : 'icon-file-attach-sm gif',
			'mp4' : 'icon-file-attach-sm mp4',
			'mov' : 'icon-file-attach-sm mov'
		}

		// 브라우저 체크
		// IE : 익스플로러 , ETC : 기타
		var agent = navigator.userAgent.toLowerCase();
		var browserType = "";

		var fileJsonDataMap = ${fileJsonDataMap};
		var listMap = ${listMap};

		$(function() {
			fnValid();

		   	//드래그 방지
	        $("body").on("dragover drop",function(e){
	            console.log("d"+e);
	            return false;
        	});

			if ((navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1)) {
				browserType = "IE"
			}
			else {
				browserType = "ETC"
				//드래그이벤트는 IE가아닌 경우만 처리

				for (var i = 0; i < fileJsonDataMap.length; i++) {
					$('#img-view6_' + i).on("dragover", dragOver).on("dragleave", dragOver).on("drop", uploadFiles);
				}
			}

			fnSetDragTap(browserType);
			$(".attach-delete").removeAttr("position");

			// 기존 파일조회일경우 리스트 세팅
			if (fileJsonDataMap.length > 0) {
				fnExistsFileSelect(fileJsonDataMap);
			} else {
				alert("파일 첨부할 항목이 없습니다.")
				fnClose();
			}
		 });

		// 페이지 진입시 체크
		function fnValid() {
			var maxCountValidYn = $M.getValue("max_count_valid_yn");

			if (maxCountValidYn == "N") {
				alert("항목별 최대개수보다 많은 파일을 조회 할 수 없습니다.");
				fnClose();
			}

			// 항목 ID 중복체크
			for (var i = 0; i < fileJsonDataMap.length; i++) {
				var item = fileJsonDataMap[i].type_id;

				for (var j = i+1; j < fileJsonDataMap.length; j++) {
					if (item === fileJsonDataMap[j].type_id) {
						alert("중복되는 항목 ID가 있습니다.\n수정 후 다시 시도해주세요.");
						fnClose();
					}
				}
			}
		}

		//드래그영역문구세팅
		function fnSetDragTap(browserType) {
			// var str = '';
			// if (browserType == 'IE') {
			// 	str += '<div class="font-14 text-default">파일을 업로드 해주세요!</div>';
			// 	$('#drag_tap').html(str);
			// }
			// else {
			// 	str += '<i class="icon-drag"></i>';
			// 	str += '<div class="font-14 text-default">마우스로 드래그해서 파일을 추가해 주세요!</div>';
			// 	$('#drag_tap').html(str);
			// }
		}

		function dragOver(e){
		    e.stopPropagation();
		    e.preventDefault();

			var targetId = e.currentTarget.id;  // img-view6_0, img-view6_1 ..
			var targetIndex = targetId.substring(targetId.length -2); // _0, _1 ..

		    if (e.type == "dragover")
		    {
		        $('#drag-comment'+targetIndex).css({
		        	"outline":"10px dashed #0c0"
		        });
		    } else {
		        $('#drag-comment'+targetIndex).css({
		        	"outline":"0"
		        });
		    }
		}

		// 기존 파일이 있는경우 화면에 보여주기
		function fnExistsFileSelect(fileJsonDataMap) {
			var fileSeq;
			var fileName;
			var fileExt;
			var fileSize;

			var typeId;
			var typeName;
			var maxCount;

			var itemsSize;

			for (var i = 0; i < listMap.length; i++) {
				typeId = fileJsonDataMap[i].type_id;
				typeName = fileJsonDataMap[i].type_name;
				maxCount = fileJsonDataMap[i].max_count;
				itemsSize = listMap[i].length;

				for (var j = 0; j < listMap[i].length; j++) {
					var items = listMap[i];
					fileSeq = items[j].file_seq;
					fileName = items[j].file_name;
					fileExt = items[j].file_ext;
					fileSize = items[j].file_size;

					var tag = "";
					tag +=
							"<sapn class='file-attach-item' id='"+fileSeq+"'>"+
							"<input type='hidden' name='origin_file_seq' id='"+fileSeq+"' value='"+fileSeq+"'>"+
							"<input type='hidden' name='type_id' id='"+fileSeq+"^"+typeId+"' value='"+fileSeq+"^"+typeId+"'>"+
							"<span class='"+fileIcon[fileExt]+"' style='margin-right: 6px;'></span>"+
							"<span class='fileName'>"+fileName+"</span>"+
							"<span class='fileSize' id='fileSize"+fileSeq+"' value='"+fileSize+"'>("+fileSize+"KB)</span>"+
							"<button type='button' class='btn-default' data-index='"+fileSeq+"' onclick='imgDel("+i+", this, "+fileSeq+");'><i class='material-iconsclose font-18 text-default'></i></button>"+
							"</sapn>";

					if (itemsSize > 0) {
						$("#drag_tap_"+i).hide();
						$(".attachfile-item_"+i).append(tag);
						$(".attachfile-item_"+i).show();
					}

					fileSumSize += fileSize;
				}
				// 기존 파일 개수 세팅
				$("#file_count_"+i).html(itemsSize);
				fileTotalCount += itemsSize;
			}
			$("#file_sum_size").html(fileSumSize);
			$("#file_total_count").html(fileTotalCount);
		}

		// 드래그해서 파일 선택후 실행됨
		function uploadFiles(e) {
		    e.stopPropagation();
		    e.preventDefault();
		    dragOver(e);

			var files = e.originalEvent.dataTransfer;
			var targetId = e.currentTarget.id;
			var targetIndex = targetId.substring(targetId.length -1); // 0, 1 ..
			fnFileSelect(files, targetIndex);
			return;
		}

		// 파일 선택되면 실행
		function fnFileSelect(fileComp, targetIndex) {
			var fileObjList = fileComp.files;
			fileTotalCount += fileObjList.length;

			var thisTypeId;

			// 영역당 파일개수 제한 체크
			for (var k = 0; k < fileJsonDataMap.length; k++) {
				if (targetIndex == k) {
					thisTypeId = fileJsonDataMap[k].type_id;

					fileValidCount = fileJsonDataMap[k].max_count;
					var fileCount = $(".attachfile-item_"+targetIndex).find(".file-attach-item").length;

					if ((fileCount + fileObjList.length) > fileValidCount) {
						alert("해당 항목의 파일은 최대 "+ fileValidCount +"개 까지 업로드 가능합니다.");
						fileTotalCount -= fileObjList.length;
						return;
					}
				}
			}

		   	var checkExt = '${inputParam.file_type}' == 'img' ? imgExt : '${inputParam.file_type}' == 'etc' ? etcExt : imgExt.concat(etcExt);
			var fileExtType = '${inputParam.file_ext_type}';

			// 현재 영역에있는 파일의 개수
			var count = $(".attachfile-item_"+targetIndex).find(".file-attach-item").length;

			for (var i = 0; i < fileObjList.length; i++) {
				var fileObj = fileObjList[i];
				var fileExt = $M.getFileExt(fileObj.name).toLowerCase();
				var imgIcon = fileIcon[fileExt];

				//파일확장자를 지정한 경우
				if(fileExtType!= '') {
					// 확장자 제한이 이미지 + PDF 2종류만 허용해야되는데 안되서 변경함
					var tempExt = fileExtType.toLowerCase();
					var extArray = tempExt.split("#");

					var fileExt = $M.getFileExt(fileObj.name).toLowerCase();
					if(extArray.indexOf(fileExt) == -1) {
						if (extArray.indexOf('img') > -1 && imgExt.indexOf(fileExt) > -1) {
							console.log("이미지 허용");
						} else {
							alert( extArray.join(" ") +  "형식 파일만 업로드 가능합니다.");
							fileTotalCount -= fileObjList.length;
							$("#file_total_count").html(fileTotalCount);
							return;
						}
					}
				}

				//확장자 제한 ( 이미지 OR 일반 파일범위)
				if($M.checkFileType(fileObj.name, checkExt) == false) {
					alert('첨부할 수 있는 유효한 파일이 아닙니다.\r\n첨부 가능 확장자 : ' + checkExt);
					fileTotalCount -= fileObjList.length;
					$("#file_total_count").html(fileTotalCount);
					return;
				}

				// 총 용량 제한
				var maxSize = ${inputParam.max_size};
				var fileSize = Math.ceil(fileObj.size / 1024);	// kb환산
				var tempTotalSize = 0;
				tempTotalSize = fileSumSize + fileSize;
				if(maxSize < tempTotalSize) {
					alert("파일 총 용량 제한이 있습니다.\n가능 용량 : " +  maxSize +"KB " +  "\n현재 파일용량 :  " + fileSize + "KB" + "\n남은 파일용량 :  " + (maxSize-fileSumSize) + "KB");
					fileTotalCount -= fileObjList.length;
					$("#file_total_count").html(fileTotalCount);
					return;
				}

				var fileName = fileObj.name;
				var fileSize = Math.ceil(fileObj.size / 1024);

				// 영역별 파일개수 추가 반영
				$("#file_count_"+targetIndex).html(count + fileObjList.length);

				fnAddFileList(fileName, fileSize, fileExt, fileObj, targetIndex);
				fileSumSize += fileSize;
			}

			// 저장할 파일 모음
			for (var i = 0; i < fileObjList.length; i ++) {
				fileObjList[i].myTypeId = $M.getValue("my_type_"+targetIndex);
				myDataTranster.items.add(fileObjList[i]);
			}

			$("#file_sum_size").html(fileSumSize);
			// 파일선택시 같은파일 연속으로 선택하면 파일추가가 안되는 이슈로 추가
			$("#file_comp").val("");
			$("#"+thisTypeId).val("");
			$("#file_total_count").html(fileTotalCount);
		}

		// 파일 그리기
		function fnAddFileList(fileName, fileSize, fileExt, fileObj, targetIndex) {
			var tag = "";
			tag +=
					"<span class='file-attach-item' id='"+fileObj.lastModified+"_"+targetIndex+"'>"+
					"<span class='"+fileIcon[fileExt]+"'></span>"+
					"<span class='fileName'>"+fileName+"</span>"+
					"<span class='fileSize' id='fileSize"+fileObj.lastModified+"_"+targetIndex+"' value='"+fileSize+"'>("+fileSize+"KB)</span>"+
					"<button type='button' class='btn-default' data-index='"+fileObj.lastModified+"_"+targetIndex+"' onclick='imgDel("+targetIndex+", this);'><i class='material-iconsclose font-18 text-default'></i></button>"+
					"</span>";

			$("#drag_tap_"+targetIndex).hide();
			$(".attachfile-item_"+targetIndex).append(tag);
			$(".attachfile-item_"+targetIndex).show();
		}

		// 파일저장
		function goApply() {
			var list = myDataTranster.files;
			var myTypeArr = new Set(); // file 컴포넌트에 담을 typeId

			for (var i = 0; i < list.length; i++) {
				myTypeArr.add(list[i].myTypeId);
			}

			myTypeArr.forEach(function (value) {
				var myTypeId = value;
				var newMyDataTranster = new DataTransfer();

				for(var j = 0; j < list.length; j++) {
					if(myTypeId == list[j].myTypeId) {
						newMyDataTranster.items.add(list[j]);
					}
				}

				document.querySelector("#"+myTypeId).files = newMyDataTranster.files;
			})

			$M.setValue("save_mode", "group_multi");

			$M.goNextPageAjaxMsg('파일을 등록하시겠습니까?', '/file/upload', document.main_form, {method : 'post', contentType : false, processData : false},
				function(result) {
					if(result.success) {
						try {
			    			opener.${inputParam.parent_js_name}(result);
			    			window.close();
			    		} catch(e) {
							alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
						}
					}
			});
			return;
		}

		// 이미지 삭제
		function imgDel(targetIndex, e, fileSeq) {
			const removeTargetId = e.dataset.index;
			const removeTarget = document.getElementById(removeTargetId);
			const files = document.querySelector('#file_comp').files;
			const dataTranster = new DataTransfer();

			var fileSize = Number($('#fileSize'+removeTargetId).attr("value"));

			// 각 영역에 같은 파일을 등록했을경우 삭제할 파일을 구분하기 위해 변수 추가
			var tempRemoveTargetId = removeTargetId.substring(0, removeTargetId.length-2);

			Array.from(files)
					.filter(file => file.lastModified != tempRemoveTargetId)
					.forEach(file => {
						dataTranster.items.add(file);
					})

			// 실제 file_comp도 삭제
			document.querySelector('#file_comp').files = dataTranster.files;
			for (var i = 0; i < myDataTranster.items.length; i++) {
				if (myDataTranster.files[i].lastModified == tempRemoveTargetId && i == targetIndex) {
					myDataTranster.items.remove(i);
					break;
				}
			}

			// 영역별 현재 파일 개수 반영
			var fileCount = $(".attachfile-item_"+targetIndex).find(".file-attach-item").length;
			$("#file_count_"+targetIndex).html(fileCount - 1);

			// 해당 영역 삭제
			removeTarget.remove();
			fileTotalCount--;

			// 영역별 파일이 전부 삭제되면 drag 아이콘 표시
			if ((fileCount - 1) == 0) {
				$("#drag_tap_"+targetIndex).show();
			}

			fileSumSize -= fileSize;
			$("#file_sum_size").html(fileSumSize);
			$("#file_total_count").html(fileTotalCount);
		}

		function fnClose() {
			window.close();
		}

		function goSearchFile() {
			$("#file_comp").click();
		}

		function goAddFilePopup(target) {
			$("#"+target).click();
		}

	</script>
</head>

<body  class="bg-white class" >
	<form id="main_form" name="main_form" enctype="multipart/form-data" >
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
	        <div class="main-title">
	            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
			<!-- /타이틀영역 -->
	        <div class="content-wrap">
	        	<input type="hidden" id="upload_path" 	name="upload_path" value="${inputParam.upload_path}" >
				<div class="checklist-comment">
					<c:if test="${inputParam.file_type ne 'etc' and inputParam.file_ext_type eq '' and inputParam.img_resize ne 0}">이미지 사이즈 : ${inputParam.img_resize} (가로,세로중 큰쪽에 맞춰 리사이징 적용)</c:if>
					<c:if test="${inputParam.file_type eq 'etc' and inputParam.file_ext_type eq '' }">첨부가능파일 : txt, ppt, pptx, doc, docx, xls, xlsx, hwp, pdf</c:if>
					<c:if test="${inputParam.file_ext_type ne '' }">첨부가능파일 : ${fn:join(fn:split(inputParam.file_ext_type, '#'), ', ')}</c:if>
					<span style="float:right;" id="file_size_div">
						<sapn id="file_sum_size">0</sapn> / <fmt:formatNumber value="${inputParam.max_size }"/>KB
						<c:if test="${inputParam.total_max_count ne 0 }">(<sapn id="file_total_count">0</sapn> / ${inputParam.total_max_count }개)</c:if>
						<c:if test="${inputParam.total_max_count eq 0 }">(<sapn id="file_total_count">0</sapn>개)</c:if>
					</span>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="120px">
						<col width="">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<c:forEach items="${fileDataMap}" var="list" varStatus="status">
						<tr>
							<th class="text-right">${list.type_name}
								<input type="hidden" id="my_type_${status.index}" name="my_type_${status.index}" value="${list.type_id}">
								<div><span id="file_count_${status.index}">0</span> / ${list.max_count}</div>
								<input type="file" name="${list.type_id}" id="${list.type_id}" style="display:none;width:5px;" onChange="javascript:fnFileSelect(this, '${status.index}');" multiple>
								<div class="btn-group mt10">
									<div class="right">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goAddFilePopup('${list.type_id}');">파일찾기</button>
									</div>
								</div>
							</th>
							<td colspan="6">
								<div class="img-view6" id="img-view6_${status.index}">
									<div class="drag-comment" id="drag-comment_${status.index}">
										<div id="drag_tap_${status.index}" class="drag_tap">
											<div class="font-14 text-default" style="text-align: center;">마우스로 드래그해서 파일을 추가해 주세요!</div>
										</div>
										<div style="overflow: auto; margin-top: 5px; margin-left: 5px;">
											<div class="attachfile-item_${status.index}" id="attchfile-item_${status.index}" style="display:none;" >
											</div>
										</div>
									</div>
								</div>
							</td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
				<div  class="file-name" id="file_info" name="file_info" style="height:20px;" ></div>
				<div class="btn-group mt10">
					<div class="left">
<%--						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>--%>
					</div>
					<div class="right">
						<c:if test="${inputParam.img_resize ne 0}">
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="checkbox" id="img_resize_check_yn" name="img_resize_check_yn" value="Y" checked>
								<label for="img_resize_check_yn" class="form-check-label">이미지 리사이징</label>
							</div>
						</c:if>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	        </div>
	    </div>
	<!-- /팝업 -->
	<input type="file" name="file_comp" id="file_comp" style="display:none;width:5px;" onChange="javascript:fnFileSelect(this);" multiple>
	<input type="hidden" name="upload_type" id="upload_type" value="${inputParam.upload_type }" />
	<input type="hidden" name="prev_file_seq" id="prev_file_seq" value="${inputParam.file_seq }" />
	<input type="hidden" name="file_remove_yn" id="file_remove_yn" value="N"  />
	<input type="hidden" name="img_resize" id="img_resize" value="${inputParam.img_resize}"/>
	<input type="hidden" name="max_count_valid_yn" id="max_count_valid_yn" value="${max_count_valid_yn}"/>
	<input type="hidden" name="open_yn" id="open_yn" value="${inputParam.open_yn}" />
	<input type="hidden" name="pixel_resize_yn" id="pixel_resize_yn" value="${inputParam.pixel_resize_yn}" />
	<input type="hidden" name="max_width" id="max_width" value="${inputParam.max_width}" />
	<input type="hidden" name="max_height" id="max_height" value="${inputParam.max_height}" />
	<input type="hidden" name="kukudocs_upload_yn" id="kukudocs_upload_yn" value="${inputParam.kukudocs_upload_yn}" />
	</form>
</body>
</html>
